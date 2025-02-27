using Entities.Champion;
using GameStates;
using Photon.Pun;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class TpCapacity : CurveMovementWithPrevisualisableCapacity
    {
        public TpCapacitySO tpCapacitySo;
        private Vector3 previsualisableTPObjectForward;
        private TpMovement tpMovement;

        private int useCount = 0;
        private bool isEndCurve;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
   
            if (useCount == 0)
            {
                if (base.TryCast(targetsEntityIndexes, targetPositions) )
                {
                   
                    useCount = 1;
                    return true;
                }
            }
            else if (useCount == 1)
            {
                useCount = 2;
                return true;
            }

            return false;
        }


        
        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] customParameters)
        {
            useCount = (int)customParameters[2];
            if (useCount == 1)
            {
                UIManager.Instance.LaunchRecastCooldown(champion, tpCapacitySo.smokeDuration);
                curveObject.endCurveEvent += () => isEndCurve = true;
                curveObject.endCurveEvent -= TpChampion;
                SetCanSkipDrawing(true);
                base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
            }
            else if (useCount == 2)
            {
                
                TryTpChampion();
            }
        }

        public override object[] GetCustomSyncParameters()
        {
            object[] baseObjects = base.GetCustomSyncParameters();
            return new object[] { baseObjects[0], baseObjects[1], useCount };
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            champion.RequestSetSkipDrawingCapacity(indexOfSOInCollection, false);
            useCount = 0;
            isEndCurve = false;
            champion.RequestCancelRecacstCooldown();
            // end cooldown rpc 
          
        }

        void TryTpChampion()
        {
            if (isEndCurve)
            {
             TpChampion();   
            }
            else
            {
                curveObject.endCurveEvent += TpChampion;
            }
                champion.SyncCancelRecacstCooldownRPC();
        }
        void TpChampion()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                champion.RequestMoveChampion(
                    ChampionPlacerManager.instance.GetLauncher.LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(curveObject
                            .transform.position, champion.pointPlacerDistanceAvoidance, champion.pointPlacerColliderRadius,
                       tpCapacitySo.secondDetectionSo,  champion.championPlacerDistanceAvoider.pointAvoider).point);
            
            }

            champion.CancelCurrentCapacityRPC();
            champion.SyncResetCapacityAimedRPC();
            
           
        }


        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            tpCapacitySo = (TpCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            if (PhotonNetwork.IsMasterClient)
            {
                curveObject = PhotonNetwork.Instantiate(tpCapacitySo.tpObjectPrefab.gameObject.name, Vector3.zero,
                    Quaternion.identity).GetComponent<CurveMovement>();
                curveObject.GetComponent<TpObject>().RequestDeactivate();
                curveObject.RequestSetupRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex);
            }

            if (champion.photonView.IsMine)
            {
                
                _previsualisableCurveMovementObject.UpdatePositionAndSize(range, tpCapacitySo.smokePrefab.transform.lossyScale.x*2);
                _previsualisableCurveMovementObject.gameObject.SetActive(false);
            }
        }
    }
}