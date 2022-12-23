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

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            Debug.Log("trycast");
            if (useCount == 0)
            {
                if (base.TryCast(targetsEntityIndexes, targetPositions))
                {
                    useCount = 1;
                    return true;
                }
            }
            else if (useCount == 1)
            {
                Debug.Log("trycast bonsoir");
                useCount = 2;
                return true;
            }

            return false;
        }
        
        public void RequestUpdateClientReadyToTP()
        {
            curveObject.photonView.RPC("UpdateClientReadyForTP", RpcTarget.All);
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] customParameters)
        {
            useCount = (int)customParameters[1];
            Debug.Log(useCount);
            if (useCount == 1)
            {
                SetCanSkipDrawing(true);
                curveObject.endCurveEvent -= TpChampion;
                base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
            }
            else if (useCount == 2)
            {
                curveObject.endCurveEvent += TpChampion;
            }
        }

        public override object[] GetCustomSyncParameters()
        {
            return new object[] { base.GetCustomSyncParameters()[0], useCount };
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            champion.CancelCurrentCapacity();
            champion.RequestSetSkipDrawingCapacity(indexOfSOInCollection, false);
            useCount = 0;
        }

        void TpChampion()
        {
            if (!champion.photonView.IsMine)
            {
            champion.obstacle.enabled = false;
                
            Debug.Log("bonmatin");
            }
            champion.blocker.characterColliderBlocker.enabled = false;
            champion.SyncSetCanMoveRPC(false);
            RequestUpdateClientReadyToTP();
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
                curveObject.endCurveEvent += InitiateCooldown;
               
                curveObject.RequestSetupRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex,
                    championOfPlayerWhoMakesSecondDetection.entityIndex);
            }
        }
    }
}