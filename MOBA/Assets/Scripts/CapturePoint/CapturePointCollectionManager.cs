using System;
using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;

namespace CapturePoint
{
    public class CapturePointCollectionManager : MonoBehaviour
    {
        public CapturePoint[] GoldCapturePoints;
        public CapturePoint[] VictoryCapturePoints;

        public static CapturePointCollectionManager instance;


        private MessagePopUpManager popUpManager;

        private void Awake()
        {
            instance = this;
        }

        private void Start()
        {
            popUpManager = MessagePopUpManager.Instance;
            InitPopUpCapturePointState(GameStateMachine.Instance.GetPlayerTeam());
        }

        private void InitPopUpCapturePointState(Enums.Team team)
        {
            for (int i = 0; i < VictoryCapturePoints.Length; i++)
            {
                string pointName = VictoryCapturePoints[i].pointName;

                InitPopUpVictoryCapturePointState(i,
                    GetAllTeamPopUpEvent(pointName, team));
            }

            for (int i = 0; i < GoldCapturePoints.Length; i++)
            {
                string pointName = GoldCapturePoints[i].pointName;
                InitPopUpGoldCapturePointState(i, GetAllTeamPopUpEvent(pointName, team));
            }

            GoldCapturePoints[1].firstTeamState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateNorthRelayCaptureState(Enums.Team.Team1);
            GoldCapturePoints[1].neutralState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateNorthRelayCaptureState(Enums.Team.Neutral);
            GoldCapturePoints[1].secondTeamState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateNorthRelayCaptureState(Enums.Team.Team2);

            GoldCapturePoints[0].firstTeamState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateSouthRelayCaptureState(Enums.Team.Team1);
            GoldCapturePoints[0].neutralState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateSouthRelayCaptureState(Enums.Team.Neutral);
            GoldCapturePoints[0].secondTeamState.enterStateEventFeedback += () =>
                UIManager.Instance.UpdateSouthRelayCaptureState(Enums.Team.Team2);

            UIManager.Instance.UpdateSouthRelayCaptureState(Enums.Team.Neutral);
            UIManager.Instance.UpdateNorthRelayCaptureState(Enums.Team.Neutral);


            VictoryCapturePoints[0].capturePointValueUpdatedFeedback += OnGeneratorValueUpdatedFeedback;
        }

        private void OnGeneratorValueUpdatedFeedback(float parameter)
        {
            Debug.Log("generator pointfdqsfsdqfqsdfqsdfqsdf ");
            var generator = VictoryCapturePoints[0];
            var capturePointCurrentValue = generator.CapturePointValue;
            Debug.Log(generator.team);
            Debug.Log(generator.capturePointDirection);
            Debug.Log(generator.CapturePointValue);
                    var captureDirection = generator.capturePointDirection;
            switch (generator.team)
            {
                case Enums.Team.Neutral:
                {
                    var oldCaptureDirection = generator.neutralState.stabilityPoint - capturePointCurrentValue;
                    if (captureDirection == 1)
                    {
                        if (oldCaptureDirection > 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.firstTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team1);
                        }
                        else if (oldCaptureDirection <= 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.secondTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team2);
                        }
                    }
                    else if (captureDirection == -1)
                    {
                        if (oldCaptureDirection >= 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.firstTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team1);
                        }
                        else if (oldCaptureDirection < 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.secondTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team2);
                        }
                    }

                    break;
                }
                case Enums.Team.Team1:
                {
                    UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                        generator.firstTeamState.maxValue, generator.firstTeamState.captureValue, Enums.Team.Team1);
                    break;
                }
                case Enums.Team.Team2:
                {
                    UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                        generator.secondTeamState.maxValue, generator.secondTeamState.captureValue, Enums.Team.Team2);
                    break;
                }
            }
        }


        private GlobalDelegates.NoParameterDelegate[] GetAllTeamPopUpEvent(string pointName, Enums.Team team)
        {
            GlobalDelegates.NoParameterDelegate[] allEvents = new GlobalDelegates.NoParameterDelegate[] { };
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    allEvents = new GlobalDelegates.NoParameterDelegate[]
                    {
                        () => popUpManager.SendAllyCapturePointMessage(pointName),
                        () => popUpManager.SendAllyLosePointMessage(pointName),
                        () => popUpManager.SendEnemyCapturePointMessage(pointName),
                        () => popUpManager.SendEnemyLosePointMessage(pointName)
                    };
                    break;
                }
                case Enums.Team.Team2:
                {
                    allEvents = new GlobalDelegates.NoParameterDelegate[]
                    {
                        () => popUpManager.SendEnemyCapturePointMessage(pointName),
                        () => popUpManager.SendEnemyLosePointMessage(pointName),
                        () => popUpManager.SendAllyCapturePointMessage(pointName),
                        () => popUpManager.SendAllyLosePointMessage(pointName)
                    };
                    break;
                }
            }

            return allEvents;
        }

        private void InitPopUpGoldCapturePointState(int i,
            GlobalDelegates.NoParameterDelegate[] allEvents)
        {
            GoldCapturePoints[i].firstTeamState.enterStateEventFeedback +=
                allEvents[0];
            GoldCapturePoints[i].firstTeamState.exitStateEventFeedback += allEvents[1];
            GoldCapturePoints[i].secondTeamState.enterStateEventFeedback +=
                allEvents[2];
            GoldCapturePoints[i].secondTeamState.exitStateEventFeedback +=
                allEvents[3];
        }

        private void InitPopUpVictoryCapturePointState(int i,
            GlobalDelegates.NoParameterDelegate[] allEvents)
        {
            VictoryCapturePoints[i].firstTeamState.enterStateEventFeedback +=
                allEvents[0];
            VictoryCapturePoints[i].firstTeamState.exitStateEventFeedback += allEvents[1];
            VictoryCapturePoints[i].secondTeamState.enterStateEventFeedback +=
                allEvents[2];
            VictoryCapturePoints[i].secondTeamState.exitStateEventFeedback +=
                allEvents[3];
        }
    }
}