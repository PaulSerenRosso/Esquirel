using System;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
//Asset Menu Synthax :
//[CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO", fileName = "new ActiveCapacitySO")]
    public abstract class ActiveCapacitySO : ScriptableObject
    {
        [Tooltip("GP Name")] public string referenceName;

        [Tooltip("GD Name")] public string descriptionName;

        [TextArea(4, 4)] [Tooltip("Description of the capacity")]
        public string description;

        [Tooltip("Cooldown in second")] public float cooldown;
        
        [Tooltip("Maximum range")] public float maxRange;
        
        [Tooltip("All types of the capacity")] public List<Enums.CapacityType> types;
        
        /// <summary>
        /// return typeof(ActiveCapacity);
        /// </summary>
        /// <returns>the type of ActiveCapacity associated with this ActiveCapacitySO</returns>
        public abstract Type AssociatedType();

        [HideInInspector] public byte indexInCollection;
    }
}