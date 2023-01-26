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
           

            VictoryCapturePoints[0].capturePointValueUpdatedFeedback +=
                (float ressource) => UpdateRockMaterial(VictoryCapturePoints[0]);

           

            GoldCapturePoints[0].capturePointValueUpdatedFeedback +=
                (float ressource) => UpdateRockMaterial(GoldCapturePoints[0]);
            GoldCapturePoints[1].capturePointValueUpdatedFeedback +=
                (float ressource) => UpdateRockMaterial(GoldCapturePoints[1]);

            AddEventUIForRelay();

            VictoryCapturePoints[0].capturePointValueUpdatedFeedback += OnGeneratorValueUpdatedFeedback;
        }

        private void UpdateRockMaterial(CapturePoint capturePoint)
        {
            var capturePointCurrentValue = capturePoint.CapturePointValue;
            switch (capturePoint.team)
            {
                case Enums.Team.Neutral:
                {
                    var substractionOfNeutralStabilityPointByCurrentValue =
                        capturePoint.neutralState.stabilityPoint - capturePointCurrentValue;

                    if (substractionOfNeutralStabilityPointByCurrentValue > 0)
                    {
                        capturePoint.rockMaterial.SetFloat("_SliderColor",
                            Mathf.Max(-1,-(substractionOfNeutralStabilityPointByCurrentValue)/(capturePoint.neutralState.stabilityPoint-capturePoint.firstTeamState.captureValue)));
                    }
                    else if (substractionOfNeutralStabilityPointByCurrentValue <= 0)
                    {
                        capturePoint.rockMaterial.SetFloat("_SliderColor",
                            Mathf.Min(1,capturePointCurrentValue-capturePoint.neutralState.stabilityPoint)/ (capturePoint.secondTeamState.captureValue-capturePoint.neutralState.stabilityPoint));
                    
                    }

                    break;
                }
                case Enums.Team.Team1:
                {
                    capturePoint.rockMaterial.SetFloat("_SliderColor",
                        -(capturePoint.firstTeamState.captureValue-capturePointCurrentValue)/(capturePoint.firstTeamState.captureValue-capturePoint.firstTeamState.maxValue));
                    break;
                }
                case Enums.Team.Team2:
                {
                    
                    capturePoint.rockMaterial.SetFloat("_SliderColor",
                        ( capturePointCurrentValue-capturePoint.secondTeamState.captureValue)/ (capturePoint.secondTeamState.maxValue-capturePoint.secondTeamState.captureValue));
                    break;
                }
            }
        }

        private void AddEventUIForRelay()
        {
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
        }

        private void OnGeneratorValueUpdatedFeedback(float parameter)
        {
            var generator = VictoryCapturePoints[0];
            var capturePointCurrentValue = generator.CapturePointValue;
            var captureDirection = generator.capturePointDirection;
            switch (generator.team)
            {
                case Enums.Team.Neutral:
                {
                    var substractionOfNeutralStabilityPointByCurrentValue =
                        generator.neutralState.stabilityPoint - capturePointCurrentValue;
                    if (captureDirection == 1)
                    {
                        if (substractionOfNeutralStabilityPointByCurrentValue > 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.firstTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team1);
                        }
                        else if (substractionOfNeutralStabilityPointByCurrentValue <= 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.secondTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team2);
                        }
                    }
                    else if (captureDirection == -1)
                    {
                        if (substractionOfNeutralStabilityPointByCurrentValue >= 0)
                        {
                            UIManager.Instance.UpdateGeneratorCapturePointValue(capturePointCurrentValue,
                                generator.firstTeamState.captureValue, generator.neutralState.stabilityPoint,
                                Enums.Team.Team1);
                        }
                        else if (substractionOfNeutralStabilityPointByCurrentValue < 0)
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
    }
}