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
        private IPunObservable _punObservableImplementation;
        private IPrevisualisable currentPrevisualisable;


        public void CancelPrevisualisable()
        {
            if (currentPrevisualisable != null)
            {
                currentPrevisualisable.DisableDrawing();
                currentPrevisualisable = null;
            }
        }

        public bool CanCast()
        {
            return canCast;
        }

        public void RequestCancelCurrentCapacity()
        {
            if (currentCapacityUsed != null)
            {
                photonView.RPC("CancelCurrentCapacity", RpcTarget.MasterClient);
                photonView.RefreshRpcMonoBehaviourCache();
            }
        }

        [PunRPC]
        public void CancelCurrentCapacity()
        {
            if (currentCapacityUsed != null)
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

        public void RequestCast(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] otherParameters)
        {
            if (activeCapacities.Count <= capacityIndex) return;
            CancelPrevisualisable();
            if (!activeCapacities[capacityIndex].onCooldown)
            {
                if (activeCapacities[capacityIndex] is IPrevisualisable)
                {
                    IPrevisualisable previsualisable = (IPrevisualisable)activeCapacities[capacityIndex];
                    if (!previsualisable.GetIsDrawing() && previsualisable.GetCanDraw())
                    {
                        currentPrevisualisable = previsualisable;
                        previsualisable.EnableDrawing();
                    }
                    else if (previsualisable.GetCanSkipDrawing())
                    {
                       
                        photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities,
                            targetedPositions, null);
                        
                    }
                }
                else
                {
                    
                        photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities,
                            targetedPositions, null);
                    
                }
            }
        }


        public void LaunchCapacityWithPrevisualisable(byte capacityIndex, int[] targetedEntities,
            Vector3[] targetedPositions)
        {
            if (capacityIndex >= activeCapacities.Count) return;
            if (!activeCapacities[capacityIndex].onCooldown)
            {
                if (activeCapacities[capacityIndex] is IPrevisualisable)
                {
                    IPrevisualisable previsualisable = (IPrevisualisable)activeCapacities[capacityIndex];
                    if (previsualisable.GetIsDrawing())
                    {
                        previsualisable.SetCanDraw(false);
                        previsualisable.DisableDrawing();
                        currentPrevisualisable = null;
                        
                        photonView.RPC("CastRPC", RpcTarget.MasterClient, capacityIndex, targetedEntities,
                            targetedPositions, previsualisable.GetPrevisualisableData());
                    }
                }
            }
        }

        [PunRPC]
        public void CastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] otherParameters)
        {
            Debug.Log(capacityIndex);
            if (activeCapacities[capacityIndex] is IPrevisualisable)
            {
                IPrevisualisable previsualisable = (IPrevisualisable)activeCapacities[capacityIndex];
                if (!previsualisable.TryCastWithPrevisualisableData(targetedEntities, targetedPositions,
                        otherParameters)) return;
            }
            else
            {
                if (!activeCapacities[capacityIndex].TryCast(targetedEntities, targetedPositions)) return;
            }
            CancelCurrentCapacity();
            OnCast?.Invoke(capacityIndex, targetedEntities, targetedPositions, otherParameters);
            photonView.RPC("SyncCastRPC", RpcTarget.All, capacityIndex, targetedEntities, targetedPositions,
                activeCapacities[capacityIndex].GetCustomSyncParameters());
        }

        [PunRPC]
        public void SyncCastRPC(byte capacityIndex, int[] targetedEntities, Vector3[] targetedPositions,
            params object[] customParameters)
        {
            activeCapacities[capacityIndex].SyncCapacity(targetedEntities, targetedPositions, customParameters);

            OnCastSync?.Invoke(capacityIndex, targetedEntities, targetedPositions, customParameters);
            // play feedback
        }

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
                    OnSetCooldownFeedback?.Invoke(indexOfSOInCollection, value);
                    return;
                }
            }

            SetOnCooldownAttackRPC(value);
        }

        public void RequestToSetCanDrawCapacity(byte indexOfSOInCollection, bool value)
        {
            photonView.RPC("SetCanDrawCapacityRPC", RpcTarget.All, indexOfSOInCollection, value);
            PhotonNetwork.SendAllOutgoingCommands();
        }


        [PunRPC]
        void SetCanDrawCapacityRPC(byte indexOfSOInCollection, bool value)
        {
            for (int i = 0; i < activeCapacities.Count; i++)
            {
                if (activeCapacities[i].indexOfSOInCollection == indexOfSOInCollection)
                {
                    IPrevisualisable previsualisable = (IPrevisualisable)activeCapacities[i];
                    previsualisable.SetCanDraw(value);
                    return;
                }
            }
        }

        public void RequestToEnqueueCapacityFX(byte capacityIndex)
        {
            photonView.RPC("EnqueueCapacityFX", RpcTarget.All, capacityIndex);
        }

        public void RequestSetSkipDrawingCapacity(byte capacityIndex, bool value)
        {
            photonView.RPC("SetSkipDrawingCapacityRPC", RpcTarget.All, capacityIndex, value);
        }

        [PunRPC]
        public void SetSkipDrawingCapacityRPC(byte capacityIndex, bool value)
        {
            for (int i = 0; i < activeCapacities.Count; i++)
            {
                if (activeCapacities[i].indexOfSOInCollection == capacityIndex)
                {
                    IPrevisualisable previsualisable = (IPrevisualisable)activeCapacities[i];
                    previsualisable.SetCanSkipDrawing(value);
                }
            }
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

        public event GlobalDelegates.FourthParameterDelegate<byte, int[], Vector3[], object[]> OnCast;
        public event GlobalDelegates.FourthParameterDelegate<byte, int[], Vector3[], object[]> OnCastSync;


        public event GlobalDelegates.TwoParameterDelegate<byte, bool> OnSetCooldownFeedback;
    }
}