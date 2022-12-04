using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Champion;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace CapturePoint
{
    public class CapturePoint : Entity, IPunObservable
    {
        [SerializeField] MeshRenderer renderer;
        [SerializeField] Gradient gradient;
        private float capturePointValue;
        private CapturePointTeamState currentTeamState;
        private CapturePointState stateToStabilize;

        private CapturePointTeamState destinationState;
        private int capturePointDirection;
        [SerializeField] private float capturePointSpeed;
        [SerializeField] private CapturePointTeamState firstTeamState;
        [SerializeField] private CapturePointTeamState secondTeamState;
        [SerializeField] private CapturePointState neutralState;

        private List<GlobalDelegates.NoParameterDelegate> capturePointDelegates =
            new List<GlobalDelegates.NoParameterDelegate>();

        private List<Champion> firstTeamChampions = new List<Champion>();
        private List<Champion> secondTeamChampions = new List<Champion>();
        private Enums.CapturePointResolveType capturePointResolve;
        private float capturePointNewValue;

        protected override void OnStart()
        {
            capturePointValue = neutralState.stabilityPoint;
            capturePointDirection = 0;

            FogOfWarManager.Instance.AddFOWViewable(this);
            team = Enums.Team.Neutral;
            base.OnStart();
        }

        public override void TriggerEnter(Collider other)
        {
            if(!PhotonNetwork.IsMasterClient) return;
            Entity entity = other.GetComponent<Entity>();
            Debug.Log("bonsoir à tosu");
            if (entity != null)
            {
                Debug.Log("je vois une entity");
                Champion champion = (Champion) entity;
                if (champion != null)
                {
                    if (entity.team == Enums.Team.Team1)
                    {
                        firstTeamChampions.Add(champion);
                        ResolveTeamSupremacy();
                    }
                    else if (entity.team == Enums.Team.Team2)
                    {
                        secondTeamChampions.Add(champion);
                        ResolveTeamSupremacy();
                    }
                }
            }
        }

        public override void TriggerExit(Collider other)
        {
            if(!PhotonNetwork.IsMasterClient) return;
            Entity entity = other.GetComponent<Entity>();
            if (entity)
            {
                Champion champion = (Champion) entity;
                if (champion)
                {
                    if (entity.team == Enums.Team.Team1)
                    {
                        firstTeamChampions.Remove(champion);
                        ResolveTeamSupremacy();
                    }
                    else if (entity.team == Enums.Team.Team2)
                    {
                        secondTeamChampions.Remove(champion);
                        ResolveTeamSupremacy();
                    }
                }
            }
        }

        void ResolveTeamSupremacy()
        {
            if (secondTeamChampions.Count == 0 && firstTeamChampions.Count == 0)
            {
                capturePointResolve = Enums.CapturePointResolveType.None;
            }
            else if (secondTeamChampions.Count != 0 && firstTeamChampions.Count == 0)
            {
                capturePointResolve = Enums.CapturePointResolveType.Team2;
            }
            else if (secondTeamChampions.Count == 0 && firstTeamChampions.Count != 0)
            {
                capturePointResolve = Enums.CapturePointResolveType.Team1;
            }
            else
            {
                capturePointResolve = Enums.CapturePointResolveType.Conflict;
            }

            UpdateCapturePointDirection();
        }

        void UpdateCapturePointDirection()
        {
            if (capturePointResolve == Enums.CapturePointResolveType.Conflict)
            {
                capturePointDirection = 0;
                return;
            }


            switch (team)
            {
                case Enums.Team.Team1:
                {
                    UpdateCapturePointDirectionTeam1();
                    break;
                }
                case Enums.Team.Team2:
                {
                    UpdateCapturePointDirectionTeam2();
                    break;
                }
                case Enums.Team.Neutral:
                {
                    UpdateCapturePointDirectionNeutral();
                    break;
                }
                    break;
            }
        }


        private void UpdateCapturePointDirectionTeam1()
        {
            switch (capturePointResolve)
            {
                case Enums.CapturePointResolveType.Team2:
                {
                    capturePointDirection = 1;
                    destinationState = secondTeamState;
                    currentTeamState = firstTeamState;
                    RemoveAllCapturePointDelegatesToTick();
                    AddRangeCapturePointDelegatesToTick(TickCurrentTeamState, TickTowardsDestinationState);
                    break;
                }
                case Enums.CapturePointResolveType.None:
                {
                    UpdateDirectionTowardsStabilityPoint(firstTeamState);
                    break;
                }
                case Enums.CapturePointResolveType.Team1:
                {
                    UpdateDirectionTowardsStabilityPoint(firstTeamState);
                    break;
                }
            }
        }

        void RemoveAllCapturePointDelegatesToTick()
        {
            for (int i = 0; i < capturePointDelegates.Count; i++)
            {
                GameStateMachine.Instance.OnTick -= capturePointDelegates[i];
            }
            capturePointDelegates.Clear();
        }

        void RemoveRangeCapturePointDelegateToTick(params GlobalDelegates.NoParameterDelegate[] removedDelegates)
        {
            for (int i = 0; i < removedDelegates.Length; i++)
            {
                capturePointDelegates.Remove(removedDelegates[i]);
                GameStateMachine.Instance.OnTick -= removedDelegates[i];
            }
        }

        void AddRangeCapturePointDelegatesToTick( params GlobalDelegates.NoParameterDelegate[] addedDelegates)
        {
            for (int i = 0; i < addedDelegates.Length; i++)
            {
                capturePointDelegates.Add(addedDelegates[i]);
                GameStateMachine.Instance.OnTick += addedDelegates[i];
            }
        }

        private void UpdateCapturePointDirectionTeam2()
        {
            switch (capturePointResolve)
            {
                case Enums.CapturePointResolveType.Team1:
                {
                    capturePointDirection = -1;
                    currentTeamState = secondTeamState;
                    destinationState = firstTeamState;
                    RemoveAllCapturePointDelegatesToTick();
                    AddRangeCapturePointDelegatesToTick(TickCurrentTeamState, TickTowardsDestinationState);
                    break;
                }
                case Enums.CapturePointResolveType.None:
                {
                    UpdateDirectionTowardsStabilityPoint(secondTeamState);
                    break;
                }
                case Enums.CapturePointResolveType.Team2:
                {
                    UpdateDirectionTowardsStabilityPoint(secondTeamState);
                    break;
                }
            }
        }

        private void UpdateCapturePointDirectionNeutral()
        {
            Debug.Log(capturePointResolve);
            switch (capturePointResolve)
            {
                case Enums.CapturePointResolveType.Team1:
                {
                    destinationState = firstTeamState;
                    RemoveAllCapturePointDelegatesToTick();
                    AddRangeCapturePointDelegatesToTick( TickTowardsDestinationState);
                    capturePointDirection = -1;
                    break;
                }
                case Enums.CapturePointResolveType.Team2:
                {
                    destinationState = secondTeamState;
                    RemoveAllCapturePointDelegatesToTick();
                    AddRangeCapturePointDelegatesToTick(TickTowardsDestinationState);
                    capturePointDirection = 1;
                    break;
                }
                case Enums.CapturePointResolveType.None:
                {
                    UpdateDirectionTowardsStabilityPoint(neutralState);
                    break;
                }
            }
        }

        private void UpdateDirectionTowardsStabilityPoint(CapturePointState capturePointState)
        {
            if (capturePointValue > capturePointState.stabilityPoint)
            {
                capturePointDirection = -1;
            }
            else
            {
                capturePointDirection = 1;
            }

            Debug.Log("update direction towards stability point" + capturePointState);
            stateToStabilize = capturePointState;
            RemoveAllCapturePointDelegatesToTick();
            AddRangeCapturePointDelegatesToTick(TickTowardsStabilityPoint);
        }

        private void TickTowardsStabilityPoint()
        {
            capturePointNewValue = capturePointValue +
                                   capturePointSpeed / (float) GameStateMachine.Instance.tickRate *
                                   capturePointDirection;
            if (capturePointDirection == 1)
            {
                if (capturePointNewValue >= stateToStabilize.stabilityPoint)
                {
                    capturePointValue = stateToStabilize.stabilityPoint;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsStabilityPoint);
                    stateToStabilize = null;
                    return;
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointNewValue <= stateToStabilize.stabilityPoint)
                {
                    capturePointValue = stateToStabilize.stabilityPoint;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsStabilityPoint);
                    stateToStabilize = null;
                    return;
                }
            }

            capturePointValue = capturePointNewValue;
        }

        private void TickTowardsDestinationState()
        {
            Debug.Log("bonsoir je suis lu souvent");

            capturePointNewValue = capturePointValue +
                                   capturePointSpeed / (float) GameStateMachine.Instance.tickRate *
                                   capturePointDirection;
            if (capturePointDirection == 1)
            {
                if (capturePointNewValue >= destinationState.captureValue)
                {
                    capturePointValue = destinationState.maxValue;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsDestinationState);
                    team = destinationState.team;
                    return;
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointNewValue <= destinationState.captureValue)
                {
                    capturePointValue = destinationState.maxValue;
                    team = destinationState.team;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsDestinationState);
                    return;
                }
            }

            capturePointValue = capturePointNewValue;
        }


        private void TickCurrentTeamState()
        {
            if (capturePointDirection == 1)
            {
                if (capturePointValue > currentTeamState.captureValue)
                {
                    team = Enums.Team.Neutral;
                    currentTeamState = null;
                    RemoveRangeCapturePointDelegateToTick(TickCurrentTeamState);
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointValue < currentTeamState.captureValue)
                {
                    team = Enums.Team.Neutral;
                    currentTeamState = null;
                    RemoveRangeCapturePointDelegateToTick(TickCurrentTeamState);
                }
            }
        }

        public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
        {
            if (stream.IsWriting)
            {
                stream.SendNext(capturePointValue);
            }
            else
            {
              capturePointValue =(float) stream.ReceiveNext();
            }
        }
    }
}