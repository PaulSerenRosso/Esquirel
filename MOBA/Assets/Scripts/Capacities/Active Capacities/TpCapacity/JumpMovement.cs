using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    public class JumpMovement : CurveMovement
    {
        private ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity;
         [SerializeField] public Transform UIRoot;
        public override void SetUp(byte capacityIndex, int championIndex, int championOfPlayerWhoMakesSecondDetectionIndex)
        {
            base.SetUp(capacityIndex, championIndex, championOfPlayerWhoMakesSecondDetectionIndex);
            JumpCapacity jumpCapacity = (JumpCapacity) champion.activeCapacities[capacityIndex];
            activeAttackSlowAreaCapacity = jumpCapacity.activeAttackSlowAreaCapacity;
            endCurveEvent += LaunchActiveAttackSlowAreaCapacity;
            enabled = false;
        }
        
        

        void LaunchActiveAttackSlowAreaCapacity()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                champion.CastRPC((byte)champion.activeCapacities.IndexOf(activeAttackSlowAreaCapacity), null, null, null);    
            }
                if (GameStateMachine.Instance.GetPlayerChampion() == championOfPlayerWhoMakesSecondDetection)
            {
                if (NavMesh.SamplePosition(transform.position, out NavMeshHit hit,
                        curveCapacitySo.toleranceSecondDetection, 1))
                {
                    champion.RequestMoveChampion(hit.position);
                    
                }
            }
            
             
           
              
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            UIRoot.position = renderer.position;
        }
    }
}
