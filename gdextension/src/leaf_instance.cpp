#include "leaf_instance.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void LeafInstance::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("setPosition", "pPosition"), &LeafInstance::setPosition);
    ClassDB::bind_method(D_METHOD("getPosition"), &LeafInstance::getPosition);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "position"), "setPosition", "getPosition");

    ClassDB::bind_method(D_METHOD("setOffset", "pOffset"), &LeafInstance::setOffset);
    ClassDB::bind_method(D_METHOD("getOffset"), &LeafInstance::getOffset);
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "offset"), "setOffset", "getOffset");

    ClassDB::bind_method(D_METHOD("setIndex", "pIndex"), &LeafInstance::setIndex);
    ClassDB::bind_method(D_METHOD("getIndex"), &LeafInstance::getIndex);
    ADD_PROPERTY(PropertyInfo(Variant::INT, "index"), "setIndex", "getIndex");
}

void LeafInstance::setPosition(Vector3 pPosition)
{
    position = pPosition;
}

Vector3 LeafInstance::getPosition()
{
    return position;
}

void LeafInstance::setOffset(Vector3 pOffset)
{
    offset = pOffset;
}

Vector3 LeafInstance::getOffset()
{
    return offset;
}

void LeafInstance::setIndex(int pIndex)
{
    index = pIndex;
}

int LeafInstance::getIndex()
{
    return index;
}