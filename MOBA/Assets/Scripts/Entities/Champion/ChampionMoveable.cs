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

        public bool canMove = true;
        private Vector3 moveDirection;

        
        public bool IsMoved
        {
            get => isMoved;
            set
            {
                isMoved = value;
                if (animator)
                {
               RequestChangeBoolParameterAnimator("Move", value);
                }
            }
        }

        private bool isMoved;
        // === League Of Legends
        private int mouseTargetIndex;
        private bool isFollowing;
        private Entity entityFollow;
        public Vector3 moveDestination;

        private Vector3 oldMoveDestination;
        private IAimable currentIAimable;
        private ActiveCapacity currentCapacityAimed;
        private ITargetable targetEntity;
        public event GlobalDelegates.ThirdParameterDelegate<byte, int[], Vector3[]> currentTargetCapacityAtRangeEvent;

        //NavMesh

        [SerializeField] private NavMeshAgent agent;


        public bool CanMove()
        {
            return canMove;
        }

        void SetupNavMesh()
        {
            if (!photonView.IsMine)
            {
                agent.enabled = false;
                obstacle.enabled = true;
            }
            else
            {
                obstacle.enabled = false;
                agent.enabled = true;
                moveDestination = transform.position;
                agent.speed = currentMoveSpeed;
                agent.SetDestination(transform.position);
            }
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
            canMove = value;
            if (!value)
            {
            if (photonView.IsMine)
                agent.SetDestination(transform.position);
            IsMoved = false; 
            }
            
        }

        [PunRPC]
        public void SetCanMoveRPC(bool value)
        {
            photonView.RPC("SyncSetCanMoveRPC", RpcTarget.All, value);
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
            RequestCancelCurrentCapacity();
            isFollowing = false;
            moveDestination = position;
            moveDestination.y = transform.position.y;
        }

        public void StartMoveToTarget(Entity _entity, ActiveCapacity capacityWhichAimed,
            GlobalDelegates.ThirdParameterDelegate<byte, int[], Vector3[]> currentTargetCapacityAtRangeEvent)
        {
            if (!isFollowing ||
                (isFollowing && (entityFollow != _entity || currentCapacityAimed != capacityWhichAimed)))
            {
                RequestCancelCurrentCapacity();
                entityFollow = _entity;
                isFollowing = true;
                targetEntity = (ITargetable)entityFollow;
                currentIAimable = (IAimable)capacityWhichAimed;
                currentCapacityAimed = capacityWhichAimed;
                this.currentTargetCapacityAtRangeEvent = currentTargetCapacityAtRangeEvent;
            }
        }

        private void FollowEntity()
        {
            if (!photonView.IsMine) return;
            if (!isFollowing) return;
            if (!canMove) return;

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
                        if (currentCapacityUsed == null)
                        {
                            if ((this.transform.position - entityFollow.transform.position).sqrMagnitude >
                                currentIAimable.GetSqrtMaxRange())
                            {
                                //Debug.Log("not distance");
                                moveDestination = entityFollow.transform.position;
                                moveDestination.y = entityFollow.transform.position.y;
                            }
                            else
                            {
                                LaunchAimedCapacity();
                            }
                        }
                        else
                        {
                            LaunchAimedCapacity();
                        }
                    }
                }
                else
                {
                    RequestCancelCurrentCapacity();
                    isFollowing = false;
                    currentTargetCapacityAtRangeEvent = null;
                }
            }
            else
            {
                moveDestination = transform.position;
                RequestCancelCurrentCapacity();
                currentTargetCapacityAtRangeEvent = null;
                isFollowing = false;
            }
        }

        private void LaunchAimedCapacity()
        {
            //Debug.Log("to distance");

            moveDestination = transform.position;
            currentTargetCapacityAtRangeEvent.Invoke(currentCapacityAimed.indexOfSOInCollection, new[]
            {
                entityFollow.entityIndex
            }, new[]
            {
                entityFollow.transform.position
            });
        }


        public void RequestRotateMeshChampion(Vector3 direction)
        {
            photonView.RPC("RotateMeshChampionRPC", RpcTarget.All, direction);
        }

        [PunRPC]
        public void RotateMeshChampionRPC(Vector3 direction)
        {
            rotateParent.forward = direction;
        }

        public void RequestMoveChampion(Vector3 newPos)
        {
            photonView.RPC("MoveChampionRPC", RpcTarget.All, newPos);
        }

        [PunRPC]
        public void MoveChampionRPC(Vector3 newPos)
        {
            if (photonView.IsMine)
            {
                agent.enabled = false;
                transform.position = newPos;
                agent.enabled = true;
            }
            else
            {
                transform.position = newPos;
            }
        }

        private void CheckMoveDistance()
        {
            if (agent == null || !agent.isOnNavMesh || !canMove) return;
            if (agent.velocity.magnitude > 0.3f)
            {
                if (!IsMoved) IsMoved = true; 
                rotateParent.forward = agent.velocity.normalized;
            }
            else IsMoved = false;
           
            agent.velocity = agent.desiredVelocity;
            if (moveDestination != oldMoveDestination)
            {
                agent.SetDestination(moveDestination);
                oldMoveDestination = moveDestination;
            }
            
            moveDestination = agent.destination;
        }

        #endregion

        public event GlobalDelegates.OneParameterDelegate<Vector3> OnMove;
        public event GlobalDelegates.OneParameterDelegate<Vector3> OnMoveFeedback;
    }
}