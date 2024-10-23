#ifndef LEAFCLEANINGHANDLER_H
#define LEAFCLEANINGHANDLER_H

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include "cleaning_request.h"

namespace godot
{
    class LeafCleaningHandler : public Node
    {
        GDCLASS(LeafCleaningHandler, Node);

        private:
            int tickRate = 1;
            int ticks = 0;
            int tickCount = 0;

            Ref<MultiMesh> multimesh;

            TypedArray<CleaningRequest> requests;
            
            void UpdateTicks(double delta);
        protected:
            static void _bind_methods();

        public:
            LeafCleaningHandler();
            ~LeafCleaningHandler();

            void _ready() override;
            void _physics_process(double delta) override;

            void setTickRate(int pTickRate);
            int getTickRate();

            void setMultimesh(Ref<MultiMesh> pMultimesh);

            void RequestCleaningAtPosition(Vector2 pPosition, Vector2 pDirection, float pSize);
    };
}

#endif