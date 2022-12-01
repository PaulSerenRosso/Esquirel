using System;
using System.Runtime.CompilerServices;
using Entities.Capacities;
using ExitGames.Client.Photon.StructWrapping;
using UnityEngine;
using Photon.Pun;
using UnityEngine.AI;


namespace Entities.Champion
{
    [RequireComponent(typeof(NavMeshAgent))]
    public partial class Champion : IMoveable
    {
        public float referenceMoveSpeed;
        public float currentMoveSpeed;
        public float currentRotateSpeed;
        public bool canMove;
        private Vector3 moveDirection;

        // === League Of Legends
        private int mouseTargetIndex;
        private bool isFollowing;
        private Entity entityFollow;

        private IAimable currentIAimable;
        private ActiveCapacity currentCapacityAimed;
        private ITargetable targetEntity;
        public event GlobalDelegates.ThirdParameterDelegate<byte, int[], Vector3[]> currentTargetCapacityAtRangeEvent;

        private Vector3 movePosition;
        //NavMesh

        private NavMeshAgent agent;


        public bool CanMove()
        {
            return canMove;
        }

        void SetupNavMesh()
        {
            agent = GetComponent<NavMeshAgent>();
            agent.SetDestination(transform.position);
            if (!photonView.IsMine) agent.enabled = false;
            //NavMeshBuilder.ClearAllNavMeshes();
            //NavMeshBuilder.BuildNavMesh();
        }

        public float GetReferenceMoveSpeed()
        {
            return referenceMoveSpeed;
        }

        public float GetCurrentMoveSpeed()
        {
            return currentMoveSpeed;
        }

        public void RequestSetCanMove(bool value)
        {
        }

        [PunRPC]
        public void SyncSetCanMoveRPC(bool value)
        {
        }

        [PunRPC]
        public void SetCanMoveRPC(bool value)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanMove;
        public event GlobalDelegates.OneParameterDelegate<bool> OnSetCanMoveFeedback;

        public void RequestSetReferenceMoveSpeed(float value)
        {
        }

        [PunRPC]
        public void SyncSetReferenceMoveSpeedRPC(float value)
        {
        }

        [PunRPC]
        public void SetReferenceMoveSpeedRPC(float value)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetReferenceMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetReferenceMoveSpeedFeedback;

        public void RequestIncreaseReferenceMoveSpeed(float amount)
        {
        }

        [PunRPC]
        public void SyncIncreaseReferenceMoveSpeedRPC(float amount)
        {
        }

        [PunRPC]
        public void IncreaseReferenceMoveSpeedRPC(float amount)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseReferenceMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseReferenceMoveSpeedFeedback;

        public void RequestDecreaseReferenceMoveSpeed(float amount)
        {
        }

        [PunRPC]
        public void SyncDecreaseReferenceMoveSpeedRPC(float amount)
        {
        }

        [PunRPC]
        public void DecreaseReferenceMoveSpeedRPC(float amount)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseReferenceMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseReferenceMoveSpeedFeedback;

        public void RequestSetCurrentMoveSpeed(float value)
        {
        }

        [PunRPC]
        public void SyncSetCurrentMoveSpeedRPC(float value)
        {
        }

        [PunRPC]
        public void SetCurrentMoveSpeedRPC(float value)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnSetCurrentMoveSpeedFeedback;

        public void RequestIncreaseCurrentMoveSpeed(float amount)
        {
        }

        [PunRPC]
        public void SyncIncreaseCurrentMoveSpeedRPC(float amount)
        {
        }

        [PunRPC]
        public void IncreaseCurrentMoveSpeedRPC(float amount)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnIncreaseCurrentMoveSpeedFeedback;

        public void RequestDecreaseCurrentMoveSpeed(float amount)
        {
        }

        [PunRPC]
        public void SyncDecreaseCurrentMoveSpeedRPC(float amount)
        {
        }

        [PunRPC]
        public void DecreaseCurrentMoveSpeedRPC(float amount)
        {
        }

        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentMoveSpeed;
        public event GlobalDelegates.OneParameterDelegate<float> OnDecreaseCurrentMoveSpeedFeedback;

        #region Battlerite

        public void SetMoveDirection(Vector3 direction)
        {
            moveDirection = direction;
        }

        #endregion

        #region League Of Legends

        public void MoveToPosition(Vector3 position)
        {
            isFollowing = false;
            movePosition = position;
            movePosition.y = transform.position.y;
            agent.SetDestination(position);
        }

        public void StartMoveToTarget(Entity _entity, ActiveCapacity capacityWhichAimed,
            GlobalDelegates.ThirdParameterDelegate<byte, int[], Vector3[]> currentTargetCapacityAtRangeEvent)
        {
            if (!isFollowing)
            {
                entityFollow = _entity;
                isFollowing = true;
                targetEntity = (ITargetable)entityFollow;
                currentIAimable = (IAimable)capacityWhichAimed;
                currentCapacityAimed = capacityWhichAimed;
                this.currentTargetCapacityAtRangeEvent += currentTargetCapacityAtRangeEvent;
            }
        }

        private void FollowEntity()
        {
            if (!photonView.IsMine) return;
            if (!isFollowing) return;

            //Debug.Log("follow");
            if (targetEntity.CanBeTargeted())
            {
               // Debug.Log("canbetarget");
                if (fowm.CheckEntityIsVisibleForPlayer(entityFollow))
                {
                    //Debug.Log("visible");
                    if (currentIAimable.TryAim(entityIndex, entityFollow.entityIndex,
                            entityFollow.transform.position))
                    {
                        //Debug.Log("tryaim");
                        if ((this.transform.position - entityFollow.transform.position).sqrMagnitude >
                            currentIAimable.GetSqrtMaxRange())
                        {
                            //Debug.Log("not distance");
                            movePosition = entityFollow.transform.position;
                            movePosition.y = transform.position.y;
                            agent.SetDestination(movePosition);
                        }
                        else
                        {
                            //Debug.Log("to distance");
                            currentTargetCapacityAtRangeEvent.Invoke(currentCapacityAimed.indexOfSOInCollection, new[]
                            {
                                entityFollow.entityIndex
                            }, new[]
                            {
                                entityFollow.transform.position
                            });
                            agent.SetDestination(transform.position);
                        }
                    }
                }
                else
                {
                    Debug.Log("not visible");
                    currentTargetCapacityAtRangeEvent = null;
                }
            }
            else
            {
                Debug.Log("can'be target");
                currentTargetCapacityAtRangeEvent = null;
                isFollowing = false;
            }
        }


        private void CheckMoveDistance()
        {
            if (agent == null) return;

            if (Vector3.Distance(transform.position, movePosition) < 0.5)
            {
                agent.SetDestination(transform.position);
                isFollowing = false;
            }
            else if (agent.velocity != Vector3.zero)
            {
                rotateParent.forward = agent.velocity.normalized;
            }
        }

        #endregion

        public event GlobalDelegates.OneParameterDelegate<Vector3> OnMove;
        public event GlobalDelegates.OneParameterDelegate<Vector3> OnMoveFeedback;
    }
}