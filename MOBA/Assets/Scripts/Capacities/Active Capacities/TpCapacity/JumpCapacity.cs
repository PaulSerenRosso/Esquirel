using System.Collections;
using System.Collections.Generic;
using Controllers.Inputs;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class JumpCapacity : CurveMovementWithPrevisualisableCapacity
    {
        private JumpMovement _jumpMovement;

    public ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity;
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (base.TryCast(targetsEntityIndexes, targetPositions))
            {

                
                return true;
            }

            return false;
        }

        
        void ActivateController()
        {
            if (champion.photonView.IsMine)
            {
            InputManager.PlayerMap.Movement.Enable();
            InputManager.PlayerMap.Attack.Enable();
            InputManager.PlayerMap.Capacity.Enable();
            InputManager.PlayerMap.MoveMouse.Enable();
            }
           
            curveObject.enabled = false;
            champion.SyncSetCanDecreaseCurrentHpRPC(true);
            champion.SetViewObstructedByObstacle(true);
            

        }

        void DeactivateController()
        {
            if (champion.photonView.IsMine)
            {
                InputManager.PlayerMap.Movement.Disable();
                InputManager.PlayerMap.Attack.Disable();
                InputManager.PlayerMap.MoveMouse.Disable();
                InputManager.PlayerMap.Capacity.Disable();
  
            }
            else
            {
                champion.obstacle.enabled = false;
            }

            champion.SetViewObstructedByObstacle(false);
            curveObject.enabled = true;
            champion.blocker.characterColliderBlocker.enabled = false;
            champion.SetCanMoveRPC(false);
            champion.SyncSetCanDecreaseCurrentHpRPC(false);
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
        {
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
            DeactivateController();
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            curveObject = champion.gameObject.AddComponent<JumpMovement>();
            curveObject.renderer = champion.rotateParent;
            _jumpMovement = (JumpMovement)curveObject;
            _jumpMovement.UIRoot = champion.uiTransform;
            curveObject.endCurveEvent += ActivateController; 
            curveObject.endCurveEvent += InitiateCooldown;
            for (int i = 0; i < champion.activeCapacities.Count; i++)
            {
            
                if (champion.activeCapacities[i] is ActiveAttackSlowAreaCapacity)
                {
                    activeAttackSlowAreaCapacity = (ActiveAttackSlowAreaCapacity)champion.activeCapacities[i];
                 
                    break;
                }
            }

            if (PhotonNetwork.IsMasterClient)
            {
                Debug.Log(championOfPlayerWhoMakesSecondDetection);
                curveObject.RequestSetupRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex, championOfPlayerWhoMakesSecondDetection.entityIndex);
            }
      
        
       
        }
        
        
    }
}
