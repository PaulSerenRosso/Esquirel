using System.Collections;
using System.Collections.Generic;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    public class JumpMovement : CurveMovement
    {
        [SerializeField] public Transform UIRoot;

        private bool isActive = false;
        public override void SetUp(byte capacityIndex, int championIndex
        )
        {
            base.SetUp(capacityIndex, championIndex);
            
          
            endCurveEvent += LaunchActiveAttackSlowAreaCapacity;
            enabled = false;
            
        }

        protected override void StartCurveMovementRPC(Vector3 startPos, Vector3 endPos)
        {
            base.StartCurveMovementRPC(startPos, endPos);
            champion.OnStartMoveChampion += ActivateChampionMove;
            champion.OnEndMoveChampion += EndJump;
            isActive = true;
            DeactivateController();
        }

        void ActivateChampionMove()
        {
            champion.blocker.characterColliderBlocker.enabled = true;
            champion.OnStartMoveChampion -= ActivateChampionMove;
        }

        void EndJump()
        {
            champion.SyncSetCanMoveRPC(true);
            champion.OnEndMoveChampion -= EndJump;
            ActivateController();
            void ActivateController()
            {
                if (champion.photonView.IsMine)
                {
                    InputManager.PlayerMap.Movement.Enable();
                    InputManager.PlayerMap.Attack.Enable();
                    InputManager.PlayerMap.Capacity.Enable();
                    InputManager.PlayerMap.MoveMouse.Enable();
                }
                champion.entityCapacityCollider.DisableEntityCollider();
                champion.SetViewObstructedByObstacle(true);
            }
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
            champion.entityCapacityCollider.DisableEntityCollider();
            champion.SetViewObstructedByObstacle(false);
            champion.SyncSetCanMoveRPC(false);
            champion.blocker.characterColliderBlocker.enabled = false;
        }


        void LaunchActiveAttackSlowAreaCapacity()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                champion.RequestMoveChampion(
                    ChampionPlacerManager.instance.GetLauncher.LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(
                        transform.position, champion.pointPlacerDistanceAvoidance,
                        champion.agent.radius, champion.championPlacerDistanceAvoider.pointAvoider).point);
                
            }
            isActive = false;
        }

        protected override void OnUpdate()
        {
           // Debug.Log(transform.position);
            if(!isActive) return;
            base.OnUpdate();
            
            UIRoot.position = renderer.position;
        }
    }
}