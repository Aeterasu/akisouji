#ifndef LEAFPOPULATOR_H
#define LEAFPOPULATOR_H

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/node_path.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/multi_mesh_instance3d.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/typed_array.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/random_number_generator.hpp>
#include "leaf_cleaning_handler.h"

namespace godot
{
    class LeafPopulator : public Node
    {
        GDCLASS(LeafPopulator, Node);

        private:
            bool isEnabled = true;
            int leavesPerPixel = 4;
            float pixelFraction = 1.0f;
            float heightmapOffset = 0.01f;
            
            Ref<Texture2D> leafmap;
            Ref<Texture2D> heightmap;
            Vector2 imageSize;

            NodePath nodePathMultimeshInstance;
            MultiMeshInstance3D* multimeshInstance;
            Ref<MultiMesh> multimesh;
            int final_instance_count = 0;

            TypedArray<Color> leafColors = {};

            NodePath nodePathLeafCleaningHandler;
            LeafCleaningHandler* leafCleaningHandler;

            TypedArray<Transform3D> transforms;
            TypedArray<Color> colors;
            TypedArray<int> indexes;

            void PopulateLeaves();
        protected:
            static void _bind_methods();

        public:
            LeafPopulator();
            ~LeafPopulator();

            void _ready() override;
            void _physics_process(double delta) override;

            void setIsEnabled(const bool pIsEnabled);
            bool getIsEnabled() const;

            void setLeavesPerPixel(const int pLeavesPerPixel);
            int getLeavesPerPixel() const;

            void setPixelFraction(const float pPixelFraction);
            float getPixelFraction() const;
        
            void setHeightmapOffset(const float pHeightmapOffset);
            float getHeightmapOffset() const;

            void setLeafmap(Ref<Texture2D> pLeafmap);
            Ref<Texture2D> getLeafmap();
        
            void setHeightmap(Ref<Texture2D> pHeightmap);
            Ref<Texture2D> getHeightmap();

            void setNodePathMultimeshInstance(NodePath pNodePath);
            NodePath getNodePathMultimeshInstance();

            void setLeafColors(TypedArray<Color> pLeafColors);
            TypedArray<Color> getLeafColors();

            Ref<MultiMesh> getMultimesh();

            void setNodePathLeafCleaningHandler(NodePath pNodePath);
            NodePath getNodePathLeafCleaningHandler();
            LeafCleaningHandler* getLeafCleaningHandler();

            bool LeafPositionSort(Transform3D a, Transform3D b);
    };
}

#endif