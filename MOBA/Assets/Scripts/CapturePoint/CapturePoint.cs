using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Champion;
using Entities.FogOfWar;
using GameStates;
using Photon.Pun;
using TMPro;
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
        public string pointName;
        private CapturePointTeamState destinationState;
        public int capturePointDirection;
        public CapturePointSO capturePointSO;
        public CapturePointState neutralState;
        public CapturePointTeamState secondTeamState;
        public CapturePointTeamState firstTeamState;
        private float capturePointSpeed;

        private List<GlobalDelegates.NoParameterDelegate> capturePointDelegates =
            new List<GlobalDelegates.NoParameterDelegate>();

        protected List<Champion> firstTeamChampions = new List<Champion>();
        protected List<Champion> secondTeamChampions = new List<Champion>();
        protected Enums.CapturePointResolveType capturePointResolve;
        private float capturePointNewValue;

        public event GlobalDelegates.OneParameterDelegate<float> capturePointValueUpdatedFeedback;
        public float CapturePointValue
        {
            get => capturePointValue;
            set
            {
                capturePointValue = value;
                capturePointValue = value;
                capturePointValueText.text = value.ToString();
                capturePointValueUpdatedFeedback?.Invoke(capturePointValue);
            }
        }


        [SerializeField] private TextMeshProUGUI capturePointValueText;

        protected override void OnStart()
        {
            capturePointSpeed = capturePointSO.capturePointSpeed;
            firstTeamState.Copy(capturePointSO.firstTeamState);
            secondTeamState.Copy(capturePointSO.secondTeamState);
            neutralState.Copy(capturePointSO.neutralState);
            CapturePointValue = neutralState.stabilityPoint;
            capturePointDirection = 0;
            FogOfWarManager.Instance.AddFOWViewable(this);
            team = Enums.Team.Neutral;
            UIManager.Instance.LookAtCamera(this.capturePointValueText.transform);
            capturePointValueText.enabled = false;
            renderer.material.color = GameStateMachine.Instance.GetTeamColor(team);
            base.OnStart();
        }

        public override void TriggerEnter(Collider other)
        {
            Entity entity = other.GetComponent<Entity>();

            if (entity != null)
            {
                Champion champion = (Champion)entity;
                if (PhotonNetwork.IsMasterClient)
                {
                    if (champion != null)
                    {
                        if (entity.team == Enums.Team.Team1)
                        {
                            firstTeamChampions.Add(champion);
                            champion.currentPoint = this;
                            // ajoute le check de la mort   
                            ResolveTeamSupremacy();
                        }
                        else if (entity.team == Enums.Team.Team2)
                        {
                            secondTeamChampions.Add(champion);
                            champion.currentPoint = this;
                            // ajoute le check de la mort
                            ResolveTeamSupremacy();
                        }
                    }
                }

                if (champion.photonView.IsMine)
                {
                    capturePointValueText.enabled = true;
                }
            }
        }


        public event GlobalDelegates.OneParameterDelegate<Champion> OnRemoveSecondTeamChampion;

        public void RemoveSecondTeamChampion(Champion champion)
        {
            secondTeamChampions.Remove(champion);
            OnRemoveSecondTeamChampion?.Invoke(champion);
            champion.currentPoint = null;
            ResolveTeamSupremacy();
        }

        public event GlobalDelegates.OneParameterDelegate<Champion> OnRemoveFirstTeamChampion;

        public void RemoveFirstTeamChampion(Champion champion)
        {
            firstTeamChampions.Remove(champion);
            OnRemoveFirstTeamChampion?.Invoke(champion);
            ResolveTeamSupremacy();
            champion.currentPoint = null;
        }

        public override void TriggerExit(Collider other)
        {
            Entity entity = other.GetComponent<Entity>();
            if (entity)
            {
                Champion champion = (Champion)entity;
                if (champion)
                {
                    if (PhotonNetwork.IsMasterClient)
                    {
                        if (entity.team == Enums.Team.Team1)
                        {
                            RemoveFirstTeamChampion(champion);
                        }
                        else if (entity.team == Enums.Team.Team2)
                        {
                            RemoveSecondTeamChampion(champion);
                        }
                    }

                    if (champion.photonView.IsMine)
                    {
                        capturePointValueText.enabled = false;
                    }
                }
            }
        }

        protected virtual void ResolveTeamSupremacy()
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

        protected void UpdateCapturePointDirection()
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

        void AddRangeCapturePointDelegatesToTick(params GlobalDelegates.NoParameterDelegate[] addedDelegates)
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
            switch (capturePointResolve)
            {
                case Enums.CapturePointResolveType.Team1:
                {
                    destinationState = firstTeamState;
                    RemoveAllCapturePointDelegatesToTick();
                    AddRangeCapturePointDelegatesToTick(TickTowardsDestinationState);
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

            stateToStabilize = capturePointState;
            RemoveAllCapturePointDelegatesToTick();
            AddRangeCapturePointDelegatesToTick(TickTowardsStabilityPoint);
        }

        private void TickTowardsStabilityPoint()
        {
            capturePointNewValue = capturePointValue +
                                   capturePointSpeed / (float)GameStateMachine.Instance.tickRate *
                                   capturePointDirection;
            if (capturePointDirection == 1)
            {
                if (capturePointNewValue >= stateToStabilize.stabilityPoint)
                {
                    CapturePointValue = stateToStabilize.stabilityPoint;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsStabilityPoint);
                    stateToStabilize = null;
                    return;
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointNewValue <= stateToStabilize.stabilityPoint)
                {
                    CapturePointValue = stateToStabilize.stabilityPoint;
                    RemoveRangeCapturePointDelegateToTick(TickTowardsStabilityPoint);
                    stateToStabilize = null;
                    return;
                }
            }

            CapturePointValue = capturePointNewValue;
        }

        private void TickTowardsDestinationState()
        {
            capturePointNewValue = capturePointValue +
                                   capturePointSpeed / (float)GameStateMachine.Instance.tickRate *
                                   capturePointDirection;
            if (capturePointDirection == 1)
            {
                if (capturePointNewValue >= destinationState.captureValue)
                {
                    CapturePointValue = destinationState.maxValue;
                    RequestUpdateCapturePointVisual( destinationState.team);
                    RemoveRangeCapturePointDelegateToTick(TickTowardsDestinationState);
                    destinationState.enterStateEvent?.Invoke();
                    neutralState.exitStateEvent?.Invoke();
//                    Debug.Log("bonsoir àtous enter ");
                    return;
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointNewValue <= destinationState.captureValue)
                {
                    RequestUpdateCapturePointVisual(destinationState.team);
                    CapturePointValue = destinationState.maxValue;
                    destinationState.enterStateEvent?.Invoke();
                    neutralState.exitStateEvent?.Invoke();
                    RemoveRangeCapturePointDelegateToTick(TickTowardsDestinationState);
                    return;
                }
            }

            CapturePointValue = capturePointNewValue;
        }


        private void TickCurrentTeamState()
        {
            if (capturePointDirection == 1)
            {
                if (capturePointValue > currentTeamState.captureValue)
                {
                    RequestUpdateCapturePointVisual(Enums.Team.Neutral);
                    currentTeamState.exitStateEvent?.Invoke();
                    neutralState.enterStateEvent?.Invoke();
                    currentTeamState = null;
                    RemoveRangeCapturePointDelegateToTick(TickCurrentTeamState);
                }
            }
            else if (capturePointDirection == -1)
            {
                if (capturePointValue < currentTeamState.captureValue)
                {
                    RequestUpdateCapturePointVisual( Enums.Team.Neutral);
                    currentTeamState.exitStateEvent?.Invoke();
                    currentTeamState = null;
                    neutralState.enterStateEvent?.Invoke();
                    RemoveRangeCapturePointDelegateToTick(TickCurrentTeamState);
                }
            }
        }

        public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info)
        {
            if (stream.IsWriting)
            {
                stream.SendNext(capturePointValue);
                stream.SendNext(capturePointDirection);
            }
            else
            {
                CapturePointValue = (float)stream.ReceiveNext();
                capturePointDirection = (int)stream.ReceiveNext();
            }
        }

        public void RequestUpdateCapturePointVisual(Enums.Team newTeam)
        {
            photonView.RPC("UpdateCapturePointVisual", RpcTarget.All, (byte)newTeam);
        }

        [PunRPC]
        public void UpdateCapturePointVisual(byte indexTeam)
        {
            Debug.Log(team);
            switch (team)
            {
                case Enums.Team.Neutral:
                {
                    neutralState.exitStateEventFeedback?.Invoke();

                    break;
                }
                case Enums.Team.Team1:
                {
                    firstTeamState.exitStateEventFeedback?.Invoke();
                    break;
                }
                case Enums.Team.Team2:
                {
                    secondTeamState.exitStateEventFeedback?.Invoke();
                    break;
                }
            }

            var newTeam = (Enums.Team)indexTeam;
            UpdateNewCapturePointState(newTeam);
            team = newTeam;
            
            renderer.material.color = GameStateMachine.Instance.GetTeamColor(team);
        }

        void UpdateNewCapturePointState(Enums.Team newTeam)
        {
            switch (newTeam)
            {
                case Enums.Team.Neutral:
                {
                    neutralState.enterStateEventFeedback?.Invoke();
                    break;
                }
                case Enums.Team.Team1:
                {
                    firstTeamState.enterStateEventFeedback?.Invoke();
                    break;
                }
                case Enums.Team.Team2:
                {
                    secondTeamState.enterStateEventFeedback?.Invoke();
                    break;
                }
            }
        }
    }
}