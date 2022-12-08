using System;
using UnityEngine;

namespace CapturePoint {
    [CreateAssetMenu(menuName = "Remote Variables/New capture point")]
    public class CapturePointSO : ScriptableObject {
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
    }

    [Serializable]
    public class CapturePointTeamState : CapturePointState {
        public float captureValue;
        public float maxValue;
        public Enums.Team team;
        public GlobalDelegates.NoParameterDelegate enterStateEvent;
        public  GlobalDelegates.NoParameterDelegate exitStateEvent;
    }
}