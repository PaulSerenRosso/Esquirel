using System;
using System.Collections;
using System.Collections.Generic;
using GameStates;
using UnityEngine;

namespace MiniMap
{
    public class MiniMapCapturePoint : MonoBehaviour
    {
        private CapturePoint.CapturePoint capturePoint;
        [SerializeField] private Sprite neutralStateSprite;


        private MiniMapIcon miniMapIcon;

        public void Start()
        {
            StartCoroutine(AddEventToCapturePoint());
        }

        private IEnumerator AddEventToCapturePoint()
        {
            yield return new WaitForEndOfFrame();
            miniMapIcon = GetComponent<MiniMapIcon>();
            capturePoint = GetComponent<CapturePoint.CapturePoint>();
            capturePoint.neutralState.enterStateEventFeedback += () => miniMapIcon.image.color = GameStateMachine.Instance.GetTeamColor(Enums.Team.Neutral);
            capturePoint.firstTeamState.enterStateEventFeedback += () => miniMapIcon.image.color = GameStateMachine.Instance.GetTeamColor(Enums.Team.Team1);
            capturePoint.secondTeamState.enterStateEventFeedback += () => miniMapIcon.image.color = GameStateMachine.Instance.GetTeamColor(Enums.Team.Team2);
        }

        public void Test() => Debug.Log("bonsoir ");
    }
}