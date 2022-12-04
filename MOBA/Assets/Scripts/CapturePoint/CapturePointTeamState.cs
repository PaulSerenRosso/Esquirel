using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CapturePoint
{
    [Serializable]
    public class CapturePointTeamState : CapturePointState
    {
        public float captureValue;
        public float maxValue;
        public Enums.Team team;
    }
}