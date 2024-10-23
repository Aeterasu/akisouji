#include "leaf_populator.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void LeafPopulator::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("setIsEnabled", "pIsEnabled"), &LeafPopulator::setIsEnabled);
    ClassDB::bind_method(D_METHOD("getIsEnabled"), &LeafPopulator::getIsEnabled);
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "isEnabled"), "setIsEnabled", "getIsEnabled");

    ClassDB::bind_method(D_METHOD("setLeavesPerPixel", "pLeavesPerPixel"), &LeafPopulator::setLeavesPerPixel);
    ClassDB::bind_method(D_METHOD("getLeavesPerPixel"), &LeafPopulator::getLeavesPerPixel);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "leavesPerPixel", PROPERTY_HINT_RANGE, "0, 64"), "setLeavesPerPixel", "getLeavesPerPixel");

    ClassDB::bind_method(D_METHOD("setLeafmap", "pLeafmap"), &LeafPopulator::setLeafmap);
    ClassDB::bind_method(D_METHOD("getLeafmap"), &LeafPopulator::getLeafmap);    
    ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "leafmap", PROPERTY_HINT_RESOURCE_TYPE, "Texture2D"), "setLeafmap", "getLeafmap");

    ClassDB::bind_method(D_METHOD("setNodePathMultimeshInstance", "pNodePath"), &LeafPopulator::setNodePathMultimeshInstance);
    ClassDB::bind_method(D_METHOD("getNodePathMultimeshInstance"), &LeafPopulator::getNodePathMultimeshInstance);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "nodePathMultimeshInstance"), "setNodePathMultimeshInstance", "getNodePathMultimeshInstance");

    ClassDB::bind_method(D_METHOD("PopulateLeaves"), &LeafPopulator::PopulateLeaves);
}

LeafPopulator::LeafPopulator()
{
    if (Engine::get_singleton()->is_editor_hint())
    {
        this->set_process_mode(Node::ProcessMode::PROCESS_MODE_DISABLED);
    }
}

LeafPopulator::~LeafPopulator()
{
    this->leafPositions.clear();
    multimesh->set_instance_count(0);
}

void LeafPopulator::_ready()
{
    if (!isEnabled)
    {
        return;
    }

    leafmap->connect("changed", Callable(this, "PopulateLeaves"));
}

void LeafPopulator::PopulateLeaves()
{
    // add null checks here

    if (leafmap == nullptr)
    {
        return;
    }

    // set up random
    Ref<RandomNumberGenerator> random;
    random.instantiate();

    // get benchmark starting time

    uint64_t startTime = Time::get_singleton()->get_ticks_msec();

    multimeshInstance = get_node<MultiMeshInstance3D>(this->nodePathMultimeshInstance);
    multimesh = multimeshInstance->get_multimesh();
    multimesh->set_transform_format(MultiMesh::TRANSFORM_3D);

    // get our image data from leaf map

    Ref<Image> image = leafmap->get_image();
    Vector2i imageSize = image->get_size();

    const float threshold = 0.01f;

    // read the image data. get the color (intensity) value, and create an array of positions.

    leafPositions.resize(imageSize.x * imageSize.y * leavesPerPixel);

    uint32_t offset = 0;

    for (int i = 0; i < imageSize.x; i++)
    {
        for (int j = 0; j < imageSize.y; j++)
        {
            float pixel = image->get_pixel(i, j).r;

            if (pixel > threshold)
            {
                int currentPixelDensity = (int)ceil(pixel * leavesPerPixel);

                for (int u = 0; u < currentPixelDensity; u++)
                {
                    leafPositions[offset] = Vector3(i + random->randf() * 1.0, 0.0f, j + random->randf() * 1.0);
                    offset++;
                }

                final_instance_count += currentPixelDensity;
            }
        }        
    }

    leafPositions.resize(final_instance_count);

    leafPositions.sort();

    // transform our leaves!

    multimesh->set_instance_count(final_instance_count);

    for (int i = 0; i < final_instance_count; i++)
    {
        multimesh->set_instance_transform(i, Transform3D()
            .rotated(Vector3(0.0f, 1, 0.0f), random->randf() * 3.14f * 2)
            .rotated(Vector3(random->randf(), 0, random->randf()), random->randf() * 3.14f * 0.25f)
            .translated(leafPositions[i]));
    }

    UtilityFunctions::print(multimesh->get_instance_count());

    // after we've done, disconnect the callable

    leafmap->disconnect("changed", Callable(this, "PopulateLeaves"));

    // benchmark

    uint64_t endTime = Time::get_singleton()->get_ticks_msec();
    uint64_t duration = endTime - startTime;

    UtilityFunctions::prints("Time taken with C++:", duration, "ms");
    
    for (int i = 0; i < 15; i++)
    {
        UtilityFunctions::prints(leafPositions[i]);
    }
}

void LeafPopulator::_physics_process(double p_delta)
{

}

void LeafPopulator::setIsEnabled(const bool pIsEnabled)
{
    isEnabled = pIsEnabled;
}

bool LeafPopulator::getIsEnabled() const
{
    return isEnabled;
}

void LeafPopulator::setLeavesPerPixel(const int pLeavesPerPixel)
{
    leavesPerPixel = pLeavesPerPixel;
}

int LeafPopulator::getLeavesPerPixel() const
{
    return leavesPerPixel;
}

void LeafPopulator::setLeafmap(Ref<Texture2D> pLeafmap)
{
    leafmap = pLeafmap;
}

Ref<Texture2D> LeafPopulator::getLeafmap()
{
    return leafmap;
}

void LeafPopulator::setNodePathMultimeshInstance(NodePath pNodePath)
{
    nodePathMultimeshInstance = pNodePath;
}

NodePath LeafPopulator::getNodePathMultimeshInstance()
{
    return nodePathMultimeshInstance;
}