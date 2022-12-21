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

        private int useCount = 0;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (useCount == 0)
            {
                if (base.TryCast(targetsEntityIndexes, targetPositions))
                {
                    useCount = 1;
                    curveObject.endCurveEvent -= TpChampion;

                    champion.RequestSetSkipDrawingCapacity(indexOfSOInCollection, true );
                    return true;
                }
            }
            else if(useCount == 1)
            {
                curveObject.endCurveEvent += TpChampion;
                useCount = 2;
                return true; 
            }


            return false;
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
            champion.RequestMoveChampion(curveObject.transform.position);
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
            }

            
        }

      
    }
}