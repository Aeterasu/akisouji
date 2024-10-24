#ifndef LEAFINSTANCE_H
#define LEAFINSTANCE_H

#include <godot_cpp/classes/ref_counted.hpp>

namespace godot
{
    class LeafInstance : public RefCounted
    {
        GDCLASS(LeafInstance, RefCounted);

        protected:
            static void _bind_methods();

        public:
            Vector3 position = Vector3(0, 0, 0);
            Vector3 offset = Vector3(0, 0, 0);
            int index = 0;

            LeafInstance(){}

            LeafInstance(Vector3 pPosition, Vector3 pOffset, int pIndex)
            {
                this->position = pPosition;
                this->offset = pOffset;
                this->index = pIndex;
            }

            ~LeafInstance(){}

            void setPosition(Vector3 pPosition);
            Vector3 getPosition();

            void setOffset(Vector3 pOffset);
            Vector3 getOffset();

            void setIndex(int pIndex);
            int getIndex();
    };
}

#endif