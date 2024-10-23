#ifndef CPPCUBEPERFORMANCETEST_H
#define CPPCUBEPERFORMANCETEST_H

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/classes/label.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

namespace godot 
{
	class CppCubePerformanceTest : public MeshInstance3D 
	{
		GDCLASS(CppCubePerformanceTest, MeshInstance3D)

	private:
		int rot_count;
        Ref<RandomNumberGenerator> random;
		Label* label;
		NodePath label_path;

	protected:
		static void _bind_methods();

	public:
		CppCubePerformanceTest();
		~CppCubePerformanceTest();

		void _ready() override;
        void RotateRandom();

        void set_rot_count(const int p_rot_count);
        int get_rot_count() const;

		void set_label_path(NodePath p_nodepath);
		NodePath get_label_path();
	};

}

#endif