using System;
using Entities.Capacities;
using UnityEngine;
using Photon.Pun;

namespace Entities.Champion
{
    public partial class Champion : ICastable
    {
        public byte[] abilitiesIndexes = new byte[2];
        public byte ultimateAbilityIndex;

        public bool canCast;


        public bool CanCast()
        {
            return canCast;
        }

        public void RequestCancelCurrentCapacity()
        {
            if (currentCapacityUsed != null)
            {
               photonView.RPC("CancelCurrentCapacity", RpcTarget.MasterClient);
              
            }
        }
        
        [PunRPC]
        public void CancelCurrentCapacity()
        {
           
            if(currentCapacityUsed!= null)
            currentCapacityUsed.CancelCapacity();
        }
        public void RequestSetCanCast(bool value)
        {
            photonView.RPC("CastRPC", RpcTarget.MasterClient, value);
        }

        [PunRPC]
        public void SetCanCastRPC(bool value)
        {
            canCast = value;
            OnSetCanCast?.Invoke(value);
            photonView.RPC("SyncCastRPC", RpcTarget.All, canCast);
        }

        [PunRPC]
        public void SyncSetCanCastRPC(bool value)
        {
            canCast = value;
            OnSetCanCastFeedback?.Invoke(value);
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanCast;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanCastFeedback;

        public void RequestCast(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
            
            if (!activeCapacities[capacityIndex].onCooldown)
            {
                    Debug.Log(activeCapacities[capacityIndex].GetType());
                if (activeCapacities[capacityIndex] is IPrevisualisable)
                {
                    IPrevisualisable previsualisable = (IPrevisualisable) activeCapacities[capacityIndex];
                    if (!previsualisable.GetIsDrawing())
                    {
                    previsualisable.EnableDrawing();
                    }
                    else
                    {
                        photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities,
                            targetedPositions);
                    }
                }
                else
                {
                    photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities,
                        targetedPositions);
                }
            }
            
        }

        [PunRPC]
        public void CastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
            var activeCapacity = CapacitySOCollectionManager.CreateActiveCapacity(capacityIndex, this);

            if (!activeCapacity.TryCast(targetedEntities, targetedPositions)) return;

            OnCast?.Invoke(capacityIndex, targetedEntities, targetedPositions);
            photonView.RPC("SyncCastRPC", RpcTarget.All, capacityIndex, targetedEntities, targetedPositions);
        }

        [PunRPC]
        public void SyncCastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions)
        {
            var activeCapacity = CapacitySOCollectionManager.CreateActiveCapacity(capacityIndex, this);
            OnCastFeedback?.Invoke(capacityIndex, targetedEntities, targetedPositions, activeCapacity);
        }

        public void RequestToSetOnCooldownCapacity(byte indexOfSOInCollection, bool value)
        {
            photonView.RPC("SetOnCooldownCapacityRPC", RpcTarget.All, indexOfSOInCollection, value);
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

        public void RequestToEnqueueCapacityFX(byte capacityIndex)
        {
            photonView.RPC("EnqueueCapacityFX", RpcTarget.All, capacityIndex);
        }

        [PunRPC]
        void EnqueueCapacityFX(byte capacityIndex)
        {
            for (int i = 0; i < activeCapacities.Count; i++)
            {
                if (activeCapacities[i].indexOfSOInCollection == capacityIndex)
                {
                    PoolNetworkManager.Instance.PoolRequeue(
                        CapacitySOCollectionManager
                            .GetActiveCapacitySOByIndex(activeCapacities[i].indexOfSOInCollection).fxPrefab,
                        activeCapacities[i].fxObject);
                    return;
                }
            }
        }

        public event GlobalDelegates.ThirdParameterDelegate<byte, int[], Vector3[]> OnCast;
        public event GlobalDelegates.FourthParameterDelegate<byte, int[], Vector3[], ActiveCapacity> OnCastFeedback;
    }
}