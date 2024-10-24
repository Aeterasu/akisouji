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

    ClassDB::bind_method(D_METHOD("setLeafColors", "pNodePath"), &LeafPopulator::setLeafColors);
    ClassDB::bind_method(D_METHOD("getLeafColors"), &LeafPopulator::getLeafColors);
    ADD_PROPERTY(PropertyInfo(Variant::ARRAY, "leafColors", PROPERTY_HINT_ARRAY_TYPE, "Color"), "setLeafColors", "getLeafColors");

    ClassDB::bind_method(D_METHOD("setNodePathLeafCleaningHandler", "pNodePath"), &LeafPopulator::setNodePathLeafCleaningHandler);
    ClassDB::bind_method(D_METHOD("getNodePathLeafCleaningHandler"), &LeafPopulator::getNodePathLeafCleaningHandler);
    ADD_PROPERTY(PropertyInfo(Variant::NODE_PATH, "nodePathLeafCleaningHandler"), "setNodePathLeafCleaningHandler", "getNodePathLeafCleaningHandler");

    ClassDB::bind_method(D_METHOD("PopulateLeaves"), &LeafPopulator::PopulateLeaves);

    ClassDB::bind_method(D_METHOD("getMultimesh"), &LeafPopulator::getMultimesh);
    ClassDB::bind_method(D_METHOD("getLeafCleaningHandler"), &LeafPopulator::getLeafCleaningHandler);
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
    this->leafInstances.clear();
}

void LeafPopulator::_ready()
{
    if (!isEnabled)
    {
        return;
    }

    leafCleaningHandler = get_node<LeafCleaningHandler>(this->nodePathLeafCleaningHandler);

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
    multimesh->set_instance_count(0);
    multimesh->set_transform_format(MultiMesh::TRANSFORM_3D);
    multimesh->set_use_colors(true);

    // get our image data from leaf map

    Ref<Image> image = leafmap->get_image();
    Vector2i imageSize = image->get_size();

    const float threshold = 0.01f;

    // read the image data. get the color (intensity) value, and create an array of positions.

    leafInstances.resize(imageSize.x * imageSize.y * leavesPerPixel);

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
                    // create leaf data

                    LeafInstance* instance = memnew(LeafInstance(
                        Vector3(i + random->randf() * 1.0, 0.0f, j + random->randf() * 1.0),
                        Vector3(0, 0, 0),
                        offset));
                    
                    leafInstances[offset] = Object::cast_to<LeafInstance>(instance);

                    // next!               

                    offset++;
                }

                final_instance_count += currentPixelDensity;
            }
        }        
    }

    // sort the array

    leafInstances.resize(final_instance_count);

    //leafInstances.sort(); // TODO: figure out a way to distribute array as already sorted, without this unnecessary expensive step

    // transform our leaves!

    multimesh->set_instance_count(final_instance_count);

    for (int i = 0; i < final_instance_count; i++)
    {
        multimesh->set_instance_transform(i, Transform3D()
            .rotated(Vector3(0.0f, 1, 0.0f), random->randf() * 3.14f * 2)
            .rotated(Vector3((0.5f - random->randf()) * 2.0f, 0, (0.5f - random->randf()) * 2.0f), random->randf() * 3.14f * 0.25f)
            .translated(Object::cast_to<LeafInstance>(leafInstances[i])->position));

        multimesh->set_instance_color(i, leafColors[random->randi() % leafColors.size()]);
    }   

    leafCleaningHandler->setMultimesh(multimesh);
    leafCleaningHandler->leafInstances = leafInstances;
    leafCleaningHandler->mapSize = imageSize;

    UtilityFunctions::print(multimesh->get_instance_count(), " leaves");

    // after we've done, disconnect the callable

    leafmap->disconnect("changed", Callable(this, "PopulateLeaves"));

    // benchmark

    uint64_t endTime = Time::get_singleton()->get_ticks_msec();
    uint64_t duration = endTime - startTime;

    UtilityFunctions::prints("Leaves generated in:", duration, "ms");
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

void LeafPopulator::setLeafColors(TypedArray<Color> pLeafColors)
{
    leafColors = pLeafColors;
}

TypedArray<Color> LeafPopulator::getLeafColors()
{
    return leafColors;
}

Ref<MultiMesh> LeafPopulator::getMultimesh()
{
    return multimesh;
}

LeafCleaningHandler* LeafPopulator::getLeafCleaningHandler()
{
    return leafCleaningHandler;
}

void LeafPopulator::setNodePathLeafCleaningHandler(NodePath pNodePath)
{
    nodePathLeafCleaningHandler = pNodePath;
}

NodePath LeafPopulator::getNodePathLeafCleaningHandler()
{
    return nodePathLeafCleaningHandler;
}