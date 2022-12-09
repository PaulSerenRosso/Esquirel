using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    public abstract class PassiveCapacity
    {
        public byte indexOfSo; //Index Reference in CapacitySOCollectionManager

        public bool stackable;
        private int count; //Amount of Stacks

        public List<Enums.CapacityType> types; //All types of the capacity

        public abstract PassiveCapacitySO AssociatedPassiveCapacitySO();

        protected Entity entity;

        

       
        
        // sur le master 
        // si tu peux le add alors 
        // tu créer un passive tu l'ajoute dans ta liste tu lance on added qui va lancer les rpc pour les feedbacks
        // tu lance un tick 
        // qui va lancer le on remove 
        // qui lancera un rpc
        
        public void OnAdded(Entity target)
        {
            if (stackable) count++;
            entity = target;
            OnAddedEffects(entity);
        }

        /// <summary>
        /// Call when a Stack of the capicity is Added
        /// </summary>
        protected abstract void OnAddedEffects(Entity target);


        /// <summary>
        /// Call when a Stack of the capacity is Removed
        /// </summary>
        public void OnRemoved(Entity target)
        {
            OnRemovedEffects(target);
        }
        protected abstract void OnRemovedEffects(Entity target);


    }
}
