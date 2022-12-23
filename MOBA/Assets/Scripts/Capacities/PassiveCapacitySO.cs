using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    //Asset Menu Syntax :
    //[CreateAssetMenu(menuName = "Capacity/PassiveCapacitySO", fileName = "new PassiveCapacitySO")]
    public abstract class PassiveCapacitySO : ScriptableObject
    {
        [Tooltip("GP Name")] public string referenceName;

        [Tooltip("GD Name")] public string descriptionName;
        
        [Tooltip("Capacity Icon")] public Sprite icon;

    public GameObject fxPrefab;

        [TextArea(4, 4)] [Tooltip("Description of the capacity")]
        public string description;
        
        public bool stackable;

        virtual public bool TryAdded(Entity target)
        {
            if (!target.canAddPassiveCapacity) return false;
            return true; 
        }
        
        
        /// <summary>
        /// return typeof(PassiveCapacity);
        /// </summary>
        /// <returns>the type of PassiveCapacity associated with this PassiveCapacitySO</returns>
        public abstract Type AssociatedType();

        [Tooltip("All types of the capacity")] public List<Enums.CapacityType> types;

        [HideInInspector] public byte indexInCollection;
    }
}