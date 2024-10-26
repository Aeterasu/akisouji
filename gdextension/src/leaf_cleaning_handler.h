#ifndef LEAFCLEANINGHANDLER_H
#define LEAFCLEANINGHANDLER_H

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/classes/tween.hpp>
#include <godot_cpp/classes/property_tweener.hpp>
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
            
            void UpdateTicks(double delta);

            int cleanedInstancesCount = 0;
            float progress = 0.0f;

        protected:
            static void _bind_methods();

        public:
            LeafCleaningHandler();
            ~LeafCleaningHandler();

            void _ready() override;
            void _physics_process(double delta) override;

            void setTickRate(int pTickRate);
            int getTickRate();

            float getProgress() const; 

            TypedArray<CleaningRequest> requests;

            Vector2 mapSize;
            int pixelDensity = 4;
            Ref<MultiMesh> multimesh;

            TypedArray<Transform3D> *transforms;
            TypedArray<int> *indexes;
            TypedArray<bool> skips;
            int lastIndex = 0;

            TypedArray<int> indexesQueuedForCleaning;
            int cleaningQueueIndexBuffer = 256;
            int sweepPerTick = 64;
            int lastFreeRequestedQueueIndex = 0;
            void UpdateRequestIndex();

            int instanceCount = 0;

            void RequestCleaningAtPosition(Vector2 pPosition, Vector2 pDirection, float pSize);
            bool LeafPositionSort(Transform3D a, Transform3D b);
    };
}

#endif