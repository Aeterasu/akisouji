#include "cleaning_request.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void CleaningRequest::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("Complete"), &CleaningRequest::Complete);
    ClassDB::bind_method(D_METHOD("getRequestPosition"), &CleaningRequest::getRequestPosition);
    ClassDB::bind_method(D_METHOD("getRequestDirection"), &CleaningRequest::getRequestDirection);
    ClassDB::bind_method(D_METHOD("getRequestSize"), &CleaningRequest::getRequestSize);
}

void CleaningRequest::Complete()
{
    CleaningRequest::isCompleted = true;
}

Vector2 CleaningRequest::getRequestPosition() const
{
    return position;
}

Vector2 CleaningRequest::getRequestDirection() const
{
    return direction;
}

float CleaningRequest::getRequestSize() const
{
    return size;
}