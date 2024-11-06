#include "leaf_cleaning_handler.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void LeafCleaningHandler::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("setTickRate", "pTickRate"), &LeafCleaningHandler::setTickRate);
    ClassDB::bind_method(D_METHOD("getTickRate"), &LeafCleaningHandler::getTickRate);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "tickRate", PROPERTY_HINT_RANGE, "0, 60"), "setTickRate", "getTickRate");

    ClassDB::bind_method(D_METHOD("setCleaningQueueIndexBuffer", "pBufferSize"), &LeafCleaningHandler::setCleaningQueueIndexBuffer);
    ClassDB::bind_method(D_METHOD("getCleaningQueueIndexBuffer"), &LeafCleaningHandler::getCleaningQueueIndexBuffer);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "cleaningQueueIndexBuffer"), "setCleaningQueueIndexBuffer", "getCleaningQueueIndexBuffer");

    ClassDB::bind_method(D_METHOD("setSweepPerTick", "pSweeps"), &LeafCleaningHandler::setSweepPerTick);
    ClassDB::bind_method(D_METHOD("getSweepPerTick"), &LeafCleaningHandler::getSweepPerTick);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "sweepPerTick"), "setSweepPerTick", "getSweepPerTick");

    ClassDB::bind_method(D_METHOD("UpdateTicks", "delta"), &LeafCleaningHandler::UpdateTicks);
    ClassDB::bind_method(D_METHOD("RequestCleaningAtPosition", "pCleaningRequest"), &LeafCleaningHandler::RequestCleaningAtPosition);

    ClassDB::bind_method(D_METHOD("LeafPositionSort", "a", "b"), &LeafCleaningHandler::LeafPositionSort);

    ClassDB::bind_method(D_METHOD("ClearAllLeaves"), &LeafCleaningHandler::ClearAllLeaves);

    ClassDB::bind_method(D_METHOD("getInstanceCount"), &LeafCleaningHandler::getInstanceCount);
    ClassDB::bind_method(D_METHOD("getCleanedInstanceCount"), &LeafCleaningHandler::getCleanedInstanceCount);
    
    ClassDB::bind_method(D_METHOD("setLeafInterpolationWeight", "pWeight"), &LeafCleaningHandler::setLeafInterpolationWeight);
    ClassDB::bind_method(D_METHOD("getLeafInterpolationWeight"), &LeafCleaningHandler::getLeafInterpolationWeight);
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "leafInterpolationWeight"), "setLeafInterpolationWeight", "getLeafInterpolationWeight");

    ADD_SIGNAL(MethodInfo("on_leaves_cleaned", PropertyInfo(Variant::INT, "amount")));
}

LeafCleaningHandler::LeafCleaningHandler()
{
    if (Engine::get_singleton()->is_editor_hint())
    {
        this->set_process_mode(Node::ProcessMode::PROCESS_MODE_DISABLED);
    }
}

LeafCleaningHandler::~LeafCleaningHandler(){}

void LeafCleaningHandler::_ready()
{
    indexesQueuedForCleaning.resize(cleaningQueueIndexBuffer);
    indexesQueuedForCleaning.fill(-1);
}

void LeafCleaningHandler::_physics_process(double delta)
{
    ticks -= 1;

    if (ticks <= 0)
    {
        UpdateTicks(delta);
        ticks = tickRate;
    }

    int i = 0;
    int sweeps = 0;

    while (sweeps < sweepPerTick)
    {
        i++;

        if (i > cleaningQueueIndexBuffer - 1)
        {
            break;
        }

        if (int(indexesQueuedForCleaning[i]) < 0)
        {
            continue;
        }
        else
        {
            sweeps++;
            int req = int(indexesQueuedForCleaning[i]);

            Transform3D t = Transform3D((*transforms)[req]).scaled_local(Vector3(1, 1, 1) - (Vector3(1, 1, 1) * leafInterpolationWeight * delta));

            (*transforms)[req] = t;

            skips[req] = true;

            if (t.basis.get_scale().length() <= 0.1f)
            {
                t = Transform3D().scaled(Vector3(0, 0, 0));

                indexesQueuedForCleaning[i] = int(-1);

                cleanedInstancesCount += 1;
            }

            multimesh->set_instance_transform(req, t);
        }
    }
}

void LeafCleaningHandler::UpdateRequestIndex()
{

}

void LeafCleaningHandler::UpdateTicks(double delta)
{
    tickCount++;

    if (requests.size() <= 0)
    {
        return;
    }

    int cleaned = 0;

    for (int i = requests.size() - 1; i > 0; i--)
    {
        Ref<CleaningRequest> request = requests[i];
        Vector2 requestPosition = request->getRequestPosition().rotated(request->getRequestDirection().angle());

        int firstSuitableIndex = (*transforms).bsearch_custom(Transform3D()
            .translated(Vector3(requestPosition.x, 0.0f, requestPosition.y)), 
            Callable(this, "LeafPositionSort")
            );

        for (int j = 0; j < instanceCount; j++)
        {
            if (skips[j])
            {
                continue;
            }

            Vector3 origin = Transform3D((*transforms)[j]).origin;
            float size = request->getRequestSize();

            if (origin.x > requestPosition.x + size)
            {
                break;
            }
            else if (Vector2(origin.x, origin.z).distance_squared_to(requestPosition) <= size)
            {
                Vector2 direction = request->getRequestDirection();
                indexesQueuedForCleaning[lastFreeRequestedQueueIndex] = int(j);

                cleaned += 1;

                if (lastFreeRequestedQueueIndex < cleaningQueueIndexBuffer - 1)
                {
                    lastFreeRequestedQueueIndex += 1;
                }
                else
                {
                    lastFreeRequestedQueueIndex = 0;
                }
            }
        }

        if (cleaned > 0)
        {
            emit_signal("on_leaves_cleaned", cleaned);
        }

        requests.remove_at(i);
    }
}

void LeafCleaningHandler::ClearAllLeaves()
{
    int cleaned = 0;

    for (int i = 0; i < instanceCount; i++)
    {
        if (skips[i])
        {
            continue;
        }

        indexesQueuedForCleaning[lastFreeRequestedQueueIndex] = int(i);

        cleaned += 1;

        if (lastFreeRequestedQueueIndex < cleaningQueueIndexBuffer - 1)
        {
            lastFreeRequestedQueueIndex += 1;
        }
        else
        {
            lastFreeRequestedQueueIndex = 0;
        }
    }

    if (cleaned > 0)
    {
        emit_signal("on_leaves_cleaned", cleaned);
    }
}

bool LeafCleaningHandler::LeafPositionSort(Transform3D a, Transform3D b)
{
    return Vector2(a.origin.x, a.origin.z) < Vector2(b.origin.x, b.origin.z);
}

void LeafCleaningHandler::setTickRate(int pTickrate)
{
    tickRate = pTickrate;
}

int LeafCleaningHandler::getTickRate()
{
    return tickRate;
}

void LeafCleaningHandler::RequestCleaningAtPosition(Vector2 pPosition, Vector2 pDirection, float pSize)
{
    requests.append(memnew(CleaningRequest(pPosition, pDirection, pSize)));
}

int LeafCleaningHandler::getInstanceCount() const
{
    return instanceCount;
}

int LeafCleaningHandler::getCleanedInstanceCount() const
{
    return cleanedInstancesCount;
}

void LeafCleaningHandler::setLeafInterpolationWeight(const float pWeight)
{
    leafInterpolationWeight = pWeight;
}

float LeafCleaningHandler::getLeafInterpolationWeight() const
{
    return leafInterpolationWeight;
}

void LeafCleaningHandler::setCleaningQueueIndexBuffer(const int pBufferSize)
{
    cleaningQueueIndexBuffer = pBufferSize;
}

int LeafCleaningHandler::getCleaningQueueIndexBuffer() const
{
    return cleaningQueueIndexBuffer;
}

void LeafCleaningHandler::setSweepPerTick(const int pSweeps)
{
    sweepPerTick = pSweeps;
}

int LeafCleaningHandler::getSweepPerTick() const
{
    return sweepPerTick;
}