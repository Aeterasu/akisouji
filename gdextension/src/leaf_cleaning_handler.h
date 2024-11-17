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
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/classes/time.hpp>
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

            int cleaningQueueIndexBuffer = 65536;
            int sweepPerTick = 64;

            float leafInterpolationWeight = 0.1f;
            
            void UpdateTicks(double delta);

            int cleanedInstancesCount = 0;

        protected:
            static void _bind_methods();

        public:
            LeafCleaningHandler();
            ~LeafCleaningHandler();

            void _ready() override;
            void _physics_process(double delta) override;

            void setTickRate(int pTickRate);
            int getTickRate();

            int getInstanceCount() const;
            int getCleanedInstanceCount() const;

            int getCleaningQueueIndexBuffer() const;
            void setCleaningQueueIndexBuffer(const int pBufferSize);

            int getSweepPerTick() const;
            void setSweepPerTick(const int pSweeps);

            void setLeafInterpolationWeight(const float pWeight);
            float getLeafInterpolationWeight() const;

            TypedArray<CleaningRequest> requests;

            Vector2 mapSize;
            int pixelDensity = 4;
            Ref<MultiMesh> multimesh;

            TypedArray<Transform3D> transforms;
            TypedArray<Color> colors;
            TypedArray<int> indexes;
            TypedArray<bool> skips;
            int lastIndex = 0;

            TypedArray<int> indexesQueuedForCleaning;
            int lastFreeRequestedQueueIndex = 0;
            void UpdateRequestIndex();

            int instanceCount = 0;

            void RequestCleaningAtPosition(Vector2 pPosition, Vector2 pDirection, Vector2 pSize);
            bool LeafPositionSort(Transform3D a, Transform3D b);

            void ClearAllLeaves();

            float ManhattanDistance(Vector2 a, Vector2 b)
            {
                return Math::abs(a.x - b.x) + Math::abs(a.y - b.y);
            }

            float IsLeft(Vector2 p0, Vector2 p1, Vector2 p2 )
            {
                return ((p1.x - p0.x) * (p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y));
            }

            bool IsPointInRectangle(Vector2 X, Vector2 Y, Vector2 Z, Vector2 W, Vector2 P)
            {
                return (IsLeft(X, Y, P) > 0 && IsLeft(Y, Z, P) > 0 && IsLeft(Z, W, P) > 0 && IsLeft(W, X, P) > 0);
            }
    };
}

#endif