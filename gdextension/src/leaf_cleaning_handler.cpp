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

        for (int j = 0; j < multimesh->get_instance_count(); j++)
        {

            Transform3D transform = multimesh->get_instance_transform(j);
            CleaningRequest *request = Object::cast_to<CleaningRequest>(requests[i]);

            if (Vector2(transform.origin.x, transform.origin.z).distance_to(request->getRequestPosition()) > request->getRequestSize())
            {
                continue;
            }

            multimesh->set_instance_transform(j, transform.translated(Vector3(request->getRequestDirection().x * delta, 0.0f, request->getRequestDirection().y * delta)));

            suitableLeaves += 1;
        }

        if (suitableLeaves <= 0)
        {
            requests.remove_at(i);
        }
    }

    tickCount++;
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