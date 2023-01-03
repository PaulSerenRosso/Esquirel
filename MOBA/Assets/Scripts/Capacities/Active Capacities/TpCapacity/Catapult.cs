using System;
using System.Collections;
using System.Collections.Generic;
using Controllers.Inputs;
using Entities.Capacities;
using Photon.Pun;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities
{
    public class Catapult : Entity, ICastable
    {
       [SerializeField] private CatapultThrowingCapacitySO catapultThrowingCapacityCapacitySo;
       [SerializeField] public Vector3 destination;


        public bool requestSended;
        private float distanceForUseCatapult;

        private float distanceSqrtForUseCatapult;

        public float DistanceForUseCatapult
        {
            get => distanceForUseCatapult;
            set
            {
                distanceForUseCatapult = value;
                distanceSqrtForUseCatapult = value * value;
            }
        }

     public List<ActiveCapacity> activeCapacities = new List<ActiveCapacity>();

        private byte soIndex;

        protected override void OnStart()
        {
            base.OnStart();
            activeCapacities = new List<ActiveCapacity>();
            soIndex = CapacitySOCollectionManager.GetActiveCapacitySOIndex(catapultThrowingCapacityCapacitySo);
         
        
            activeCapacities.Add(CapacitySOCollectionManager.CreateActiveCapacity(soIndex, this));
            activeCapacities[0].SetUpActiveCapacity(soIndex, this);
            DistanceForUseCatapult = catapultThrowingCapacityCapacitySo.referenceRange;
        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.green;
            Gizmos.DrawWireSphere(destination, 2f);
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position, catapultThrowingCapacityCapacitySo.referenceRange);
        }

        public bool CanCast()
        {
            throw new NotImplementedException();
        }

        public void RequestSetCanCast(bool value)
        {
            throw new NotImplementedException();
        }

        public void SetCanCastRPC(bool value)
        {
            throw new NotImplementedException();
        }

        public void SyncSetCanCastRPC(bool value)
        {
            throw new NotImplementedException();
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanCast;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanCastFeedback;

        public void RequestCast(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] otherParameters)
        {
            requestSended = false;
            if (activeCapacities[capacityIndex].onCooldown) return;
            if ((transform.position - targetedPositions[0]).sqrMagnitude > distanceSqrtForUseCatapult) return;
            photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities, targetedPositions,
                otherParameters);
            requestSended = true;


        }

        [PunRPC]
        public void CastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] otherParameters)
        {
            if (!activeCapacities[capacityIndex].TryCast(targetedEntities, targetedPositions)) return;
            photonView.RPC("SyncCastRPC", RpcTarget.All, capacityIndex, targetedEntities, targetedPositions,
                activeCapacities[capacityIndex].GetCustomSyncParameters());
            OnCast?.Invoke(capacityIndex, targetedEntities, targetedPositions, activeCapacities[capacityIndex].GetCustomSyncParameters());
        }

        [PunRPC]
        public void SyncCastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] customParameters)
        {
            activeCapacities[capacityIndex].SyncCapacity(targetedEntities, targetedPositions, customParameters);
            OnCastSync?.Invoke(capacityIndex, targetedEntities, targetedPositions, customParameters);
        }

        public event GlobalDelegates.FourthParameterDelegate<byte, int[], Vector3[], object[]> OnCast;


        public void RequestToSetOnCooldownCapacity(byte indexOfSOInCollection, bool value)
        {
            photonView.RPC("SetOnCooldownCapacityRPC", RpcTarget.All, indexOfSOInCollection, value);
            PhotonNetwork.SendAllOutgoingCommands();
        }


        [PunRPC]
        void SetOnCooldownCapacityRPC(byte indexOfSOInCollection, bool value)
        {
            
      
            for (int i = 0; i < activeCapacities.Count; i++)
            {
                if (activeCapacities[i].indexOfSOInCollection == indexOfSOInCollection)
                {
                  
                    activeCapacities[i].onCooldown = value;
                    return;
                }
            }

        }
        public event GlobalDelegates.FourthParameterDelegate<byte, int[], Vector3[], object[]> OnCastSync;
    }
}