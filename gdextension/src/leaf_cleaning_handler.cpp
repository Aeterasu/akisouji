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

    ClassDB::bind_method(D_METHOD("AreThereLeavesInRadius", "pPosition", "pRadius"), &LeafCleaningHandler::AreThereLeavesInRadius);

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

        int i = 0;
        int sweeps = 0;

        while (sweeps < sweepPerTick)
        {
            if (i > cleaningQueueIndexBuffer - 1)
            {
                break;
            }

            if (int(indexesQueuedForCleaning[i]) < 0)
            {
                i++;
                continue;
            }
            else
            {
                sweeps++;
                int req = int(indexesQueuedForCleaning[i]);

                Color c = Color(colors[req]).lerp(Color(0.0, 0.0, 0.0, 0.0), leafInterpolationWeight * (delta * tickRate));

                if (c.a <= 0.1f)
                {
                    c = Color(0.0, 0.0, 0.0, 0.0);
                    indexesQueuedForCleaning[i] = -1;
                    cleanedInstancesCount++;
                }

                colors[req] = c;
                multimesh->set_instance_color(req, c);
            }

            i++;
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
        Vector2 requestPosition = request->getRequestPosition();
        Vector2 requestDirection = request->getRequestDirection();
        Vector2 requestSize = request->getRequestSize();

        Vector2 A = Vector2(-requestSize.x * 0.5f, -requestSize.y * 0.5f);
        Vector2 B = Vector2(requestSize.x * 0.5f, -requestSize.y * 0.5f);
        Vector2 C = Vector2(requestSize.x * 0.5f, requestSize.y * 0.5f);
        Vector2 D = Vector2(-requestSize.x * 0.5f, requestSize.y * 0.5f);

        float angle = requestDirection.angle();

        A = Vector2(A.x * Math::cos(angle) - A.y * Math::sin(angle), A.x * Math::sin(angle) + A.y * Math::cos(angle));
        B = Vector2(B.x * Math::cos(angle) - B.y * Math::sin(angle), B.x * Math::sin(angle) + B.y * Math::cos(angle));
        C = Vector2(C.x * Math::cos(angle) - C.y * Math::sin(angle), C.x * Math::sin(angle) + C.y * Math::cos(angle));
        D = Vector2(D.x * Math::cos(angle) - D.y * Math::sin(angle), D.x * Math::sin(angle) + D.y * Math::cos(angle));

        A += requestPosition;
        B += requestPosition;
        C += requestPosition;
        D += requestPosition;

        float minReqPos = Math::min(Math::min(A.x, B.x), Math::min(C.x, D.x));
        float maxReqPos = Math::max(Math::max(A.x, B.x), Math::max(C.x, D.x));

        int firstSuitableIndex = transforms.bsearch_custom(Transform3D()
            .translated(Vector3(minReqPos, 0.0f, 0.0f)), 
            Callable(this, "LeafPositionSort")
            );

        for (int j = firstSuitableIndex; j < instanceCount; j++)
        {
            if (skips[j])
            {
                continue;
            }

            Vector3 origin = Transform3D(transforms[j]).origin;

            if (origin.x > requestPosition.x + Math::max(requestSize.x, requestSize.y))
            {
                break;
            }
            else if (IsPointInRectangle(A, B, C, D, Vector2(origin.x, origin.z)))
            {
                indexesQueuedForCleaning[lastFreeRequestedQueueIndex] = j;

                cleaned += 1;
                skips[j] = true;

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

        requests.remove_at(i);
    }

    if (cleaned > 0)
    {
        emit_signal("on_leaves_cleaned", cleaned);
    }
}

bool LeafCleaningHandler::AreThereLeavesInRadius(Vector2 pPosition, float pRadius)
{
    Vector2 A = Vector2(-pRadius * 0.5f, -pRadius * 0.5f);
    Vector2 B = Vector2(pRadius * 0.5f, -pRadius * 0.5f);
    Vector2 C = Vector2(pRadius * 0.5f, pRadius * 0.5f);
    Vector2 D = Vector2(-pRadius * 0.5f, pRadius * 0.5f);

    A += pPosition;
    B += pPosition;
    C += pPosition;
    D += pPosition;

    float minReqPos = Math::min(Math::min(A.x, B.x), Math::min(C.x, D.x));
    float maxReqPos = Math::max(Math::max(A.x, B.x), Math::max(C.x, D.x));

    int firstSuitableIndex = transforms.bsearch_custom(Transform3D()
        .translated(Vector3(minReqPos, 0.0f, 0.0f)), 
        Callable(this, "LeafPositionSort")
        );

    for (int j = firstSuitableIndex; j < instanceCount; j++)
    {
        if (skips[j])
        {
            continue;
        }

        Vector3 origin = Transform3D(transforms[j]).origin;

        if (origin.x > pPosition.x + pRadius)
        {
            return false;
        }
        else if (IsPointInRectangle(A, B, C, D, Vector2(origin.x, origin.z)))
        {
            return true;
        }
    }

    return false;
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
    return a.origin.x < b.origin.x;
}

void LeafCleaningHandler::setTickRate(int pTickrate)
{
    tickRate = pTickrate;
}

int LeafCleaningHandler::getTickRate()
{
    return tickRate;
}

void LeafCleaningHandler::RequestCleaningAtPosition(Vector2 pPosition, Vector2 pDirection, Vector2 pSize)
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