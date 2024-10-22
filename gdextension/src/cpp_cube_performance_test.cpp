#include "cpp_cube_performance_test.h"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void CppCubePerformanceTest::_bind_methods() 
{
	ClassDB::bind_method(D_METHOD("get_rot_count"), &CppCubePerformanceTest::get_rot_count);
	ClassDB::bind_method(D_METHOD("set_rot_count", "p_rot_count"), &CppCubePerformanceTest::set_rot_count);

	ADD_PROPERTY(PropertyInfo(Variant::INT, "rot_count"), "set_rot_count", "get_rot_count");
}

CppCubePerformanceTest::CppCubePerformanceTest() 
{
    if (Engine::get_singleton()->is_editor_hint())
        set_process_mode(Node::ProcessMode::PROCESS_MODE_DISABLED);
    
    rot_count = 250000;
    random.instantiate();
}

CppCubePerformanceTest::~CppCubePerformanceTest() 
{
    set_rotation(Vector3(0, 0, 0));
	// Add your cleanup here.
}

void CppCubePerformanceTest::_ready()
{
    CppCubePerformanceTest::label=get_node<Label>(NodePath("../Label"));
    uint64_t startTime = Time::get_singleton()->get_ticks_msec();

    for (int i = 0; i < rot_count; i++)
    {
        CppCubePerformanceTest::RotateRandom();
    }

    uint64_t endTime = Time::get_singleton()->get_ticks_msec();
    uint64_t duration = endTime - startTime;

    UtilityFunctions::prints("Time taken with C++:", duration, "ms");
    CppCubePerformanceTest::label->set_text(CppCubePerformanceTest::label->get_text() + "Time taken with C++: " + String::num_int64(duration) + " ms");
}

void CppCubePerformanceTest::RotateRandom()
{
    // identical gdscript code
    // rotation += Vector3(1, 0, 0) * randf() + Vector3(0, 1, 0) * randf() + Vector3(0, 0, 1) * randf()

    set_rotation(get_rotation() + Vector3(1, 0, 0) * random->randf() + Vector3(0, 1, 0) * random->randf() + Vector3(0, 0, 1) * random->randf());
}

void CppCubePerformanceTest::set_rot_count(const int p_rot_count)
{
    CppCubePerformanceTest::rot_count = p_rot_count;
}

int CppCubePerformanceTest::get_rot_count() const
{
    return CppCubePerformanceTest::rot_count;
}