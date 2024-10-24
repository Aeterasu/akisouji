#include "leaf_cleaning_handler.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void LeafCleaningHandler::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("setTickRate", "pTickRate"), &LeafCleaningHandler::setTickRate);
    ClassDB::bind_method(D_METHOD("getTickRate"), &LeafCleaningHandler::getTickRate);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "tickRate", PROPERTY_HINT_RANGE, "0, 60"), "setTickRate", "getTickRate");

    ClassDB::bind_method(D_METHOD("setMultimesh", "pMultimesh"), &LeafCleaningHandler::setMultimesh);

    ClassDB::bind_method(D_METHOD("UpdateTicks", "delta"), &LeafCleaningHandler::UpdateTicks);
    ClassDB::bind_method(D_METHOD("RequestCleaningAtPosition", "pCleaningRequest"), &LeafCleaningHandler::RequestCleaningAtPosition);

    ClassDB::bind_method(D_METHOD("LeafPositionSort", "a", "b"), &LeafCleaningHandler::LeafPositionSort);
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

}

void LeafCleaningHandler::_physics_process(double delta)
{
    ticks -= 1;

    if (ticks <= 0)
    {
        UpdateTicks(delta);
        ticks = tickRate;
    }

    if (requestedLeafIndexes.size() > 0)
    {
        for (int i = requestedLeafIndexes.size() - 1; i > 0; i--)
        {
            Ref<LeafInstance> leaf = Object::cast_to<LeafInstance>(leafInstances[requestedLeafIndexes[i]]);

            Ref<Tween> tween = create_tween();
            tween->set_parallel(true);
            tween->tween_property(*leaf, "position", leaf->position + leaf->offset, 0.3f);
            tween->tween_property(*leaf, "offset", Vector3(0, 0, 0), 0.3f);
            tween.unref();

            movingLeafIndexes.append(requestedLeafIndexes[i]);
            requestedLeafIndexes.remove_at(i);
        }
    }

    if (movingLeafIndexes.size() > 0)
    {
        for (int i = movingLeafIndexes.size() - 1; i > 0; i--)
        {
            Ref<LeafInstance> leaf = Object::cast_to<LeafInstance>(leafInstances[movingLeafIndexes[i]]);

            Transform3D transform = multimesh->get_instance_transform(movingLeafIndexes[i]);
            transform.origin = leaf->position;
            multimesh->set_instance_transform(movingLeafIndexes[i], transform);

            if (leaf->offset.length() <= 0.02f)
            {
                movingLeafIndexes.remove_at(i);
            }
        }
    }
}

void LeafCleaningHandler::UpdateTicks(double delta)
{
    if (requests.size() <= 0)
    {
        return;
    }

    for (int i = requests.size() - 1; i > 0; i--)
    {
        int suitableLeaves = 0;
        CleaningRequest *request = Object::cast_to<CleaningRequest>(requests[i]);

        Vector2 requestPosition = request->getRequestPosition();

        int firstSuitableIndex = 0;

        firstSuitableIndex = leafInstances.bsearch_custom(
            memnew(LeafInstance(
                Vector3(requestPosition.x - request->getRequestSize() / 2, 0.0f, requestPosition.y - request->getRequestSize() / 2), 
                Vector3(0.0f, 0.0f, 0.0f), 
                0)), 
            Callable(this, "LeafPositionSort"));

        if (firstSuitableIndex > 0)
        {
            firstSuitableIndex -= 1;
        }
        
        for (int j = firstSuitableIndex; j < multimesh->get_instance_count(); j++)
        {
            Transform3D transform = multimesh->get_instance_transform(j);
            if (Vector2(transform.origin.x, transform.origin.z).distance_squared_to(requestPosition) < request->getRequestSize())
            {
                Ref<LeafInstance> leaf = leafInstances[j];
                leaf->offset = Vector3(request->getRequestDirection().x * request->getRequestSize(),
                    0.0f,
                    request->getRequestDirection().y * request->getRequestSize());
                requestedLeafIndexes.append(leaf->index);

                suitableLeaves += 1;
            }

            if (transform.origin.z > requestPosition.y + request->getRequestSize() + 0.1f)
            {
                j += mapSize.y;

                if (transform.origin.x > requestPosition.x + request->getRequestSize() + 0.1f)
                {
                    break;
                }
            }
        }

        if (suitableLeaves <= 0)
        {
            requests.remove_at(i);
        }
    }

    tickCount++;
}

bool LeafCleaningHandler::LeafPositionSort(Ref<LeafInstance> a, Ref<LeafInstance> b)
{
    return Vector2(a->position.x, a->position.z) < Vector2(b->position.x, b->position.z);
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
    Ref<CleaningRequest> cleaningRequest = memnew(CleaningRequest(pPosition, pDirection, pSize));
    requests.append(cleaningRequest);
}

void LeafCleaningHandler::setMultimesh(Ref<MultiMesh> pMultimesh)
{
    multimesh = pMultimesh;
}