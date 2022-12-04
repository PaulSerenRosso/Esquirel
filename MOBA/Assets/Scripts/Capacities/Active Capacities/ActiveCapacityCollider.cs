using Entities;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    public abstract class ActiveCapacityCollider : MonoBehaviour
    {public Enums.Team team;
        public abstract void CollideWithEntity(Entity entityCollided);
        public abstract void InitCapacityCollider(ActiveCapacity activeCapacity);

        void OnTriggerEnter(Collider other)
        {
            Debug.Log("bonsoir je suis lufdsfdsf");
            Entity entity = other.GetComponent<Entity>();
            if (entity != null)
            {
                Debug.Log("bonsoir je suis lu");
            CollideWithEntity(entity);
            }
        }
    }
}
