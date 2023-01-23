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
            endCurveEvent += LaunchTP;
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
            champion.inCurveMovement = false;
            champion.OnStartMoveChampion -= ActivateChampionMove;
        }

        protected virtual void EndJump()
        {
            champion.OnEndMoveChampion -= EndJump;
            ActivateController();
        }

        protected virtual void ActivateController()
        {
            if (champion.photonView.IsMine)
            {
                InputManager.PlayerMap.Movement.Enable();
                InputManager.PlayerMap.Attack.Enable();
                InputManager.PlayerMap.Capacity.Enable();
            }
            champion.entityCapacityCollider.EnableEntityCollider();
            champion.entityClicker.EnableCollider = true;
            champion.SyncSetCanCatapultMovementRPC(true);
            
        }

        protected virtual void DeactivateController()
        {
            if (champion.photonView.IsMine)
            {
                InputManager.PlayerMap.Movement.Disable();
                InputManager.PlayerMap.Attack.Disable();
                InputManager.PlayerMap.Capacity.Disable();
            }
            else
            {
                champion.obstacle.enabled = false;
            }
            champion.entityCapacityCollider.DisableEntityCollider();
            champion.SyncSetCanMoveRPC(false);
            champion.blocker.characterColliderBlocker.enabled = false;
            champion.entityClicker.EnableCollider = false;
            champion.SyncSetCanCatapultMovementRPC(false);
            champion.inCurveMovement = true;
            champion.moveDestination = endPosition;
            champion.SyncResetCapacityAimedRPC();
        }


        void LaunchTP()
        {
            if (PhotonNetwork.IsMasterClient)
            {
                champion.RequestMoveChampion(
                    ChampionPlacerManager.instance.GetLauncher
                        .LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(
                            transform.position, champion.pointPlacerDistanceAvoidance,
                            champion.pointPlacerColliderRadius, curveCapacitySo.secondDetectionSo,
                            champion.championPlacerDistanceAvoider.pointAvoider).point);
            }

            isActive = false;
        }

        protected override void OnUpdate()
        {
            // Debug.Log(transform.position);
            if (!isActive) return;
            base.OnUpdate();

            UIRoot.position = renderer.position;
        }
    }
}