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
            Entity entity = other.GetComponent<EntityCapacityCollider>().GetEntity;
            if (entity != null)
            {
                CollideWithEntity(entity);
            }
        }
    }
}
