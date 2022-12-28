using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities
{
    public class Catapult : Entity
    {
        [SerializeField] private CatapultCapacitySO catapultCapacitySO;
        private CatapultCapacity catapultCapacity;
        [SerializeField]
        private Vector3 destination;

        private byte soIndex;
        protected override void OnStart()
        {
            base.OnStart();
            soIndex = CapacitySOCollectionManager.GetActiveCapacitySOIndex(catapultCapacitySO);
            catapultCapacity= (CatapultCapacity) CapacitySOCollectionManager.CreateActiveCapacity(soIndex, this);
            catapultCapacity.SetUpActiveCapacity(soIndex, this);
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(destination, 2f);
        }
    }
}