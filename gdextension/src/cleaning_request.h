#ifndef CLEANINGREQUEST_H
#define CLEANINGREQUEST_H

#include <godot_cpp/classes/ref_counted.hpp>

namespace godot
{
    class CleaningRequest : public RefCounted
    {
        GDCLASS(CleaningRequest, RefCounted);

        private:
            Vector2 position;
            Vector2 direction;
            float size;

        protected:
            static void _bind_methods();

        public:
            CleaningRequest(){}

            CleaningRequest(Vector2 pPosition, Vector2 pDirection, float pSize)
            {
                this->position = pPosition;
                this->direction = pDirection;
                this->size = pSize;
            }

            ~CleaningRequest(){} 

            Vector2 getRequestPosition() const;
            Vector2 getRequestDirection() const;
            float getRequestSize() const;
    };
}

#endif