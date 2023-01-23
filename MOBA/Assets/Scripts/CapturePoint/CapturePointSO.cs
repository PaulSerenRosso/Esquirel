using System;
using UnityEngine;

namespace CapturePoint {
    [CreateAssetMenu(menuName = "Remote Variables/New capture point")]
    public class CapturePointSO : ScriptableObject
    {

   
        [Header("FOW View Range")] public float baseViewRange;
        public float viewRange;

        [Header("Capture Point")] public float capturePointSpeed;

        [Header("Capture state")] public CapturePointTeamState firstTeamState;
        public CapturePointTeamState secondTeamState;
        public CapturePointState neutralState;
    }

    [Serializable]
    public class CapturePointState {
        public float stabilityPoint;
        public GlobalDelegates.NoParameterDelegate enterStateEvent;
        public  GlobalDelegates.NoParameterDelegate exitStateEvent;
        public GlobalDelegates.NoParameterDelegate enterStateEventFeedback;
        public  GlobalDelegates.NoParameterDelegate exitStateEventFeedback;

        public virtual void Copy(CapturePointState capturePointState)
        {
            stabilityPoint = capturePointState.stabilityPoint;
        }
    }

    [Serializable]
    public class CapturePointTeamState : CapturePointState {
        public float captureValue;
        public float maxValue;
        public Enums.Team team;

        public override void Copy(CapturePointState capturePointState)
        {
            CapturePointTeamState capturePointTeamState = (CapturePointTeamState)capturePointState;
            base.Copy(capturePointState);
            captureValue = capturePointTeamState.captureValue;
            maxValue = capturePointTeamState.maxValue;
            team = capturePointTeamState.team;
        }
    }
}