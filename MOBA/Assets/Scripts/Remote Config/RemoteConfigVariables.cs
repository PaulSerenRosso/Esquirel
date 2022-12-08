using CapturePoint;
using Entities.Champion;
using Entities.FogOfWar;
using UnityEngine;

namespace RemoteConfig {
    public class RemoteConfigVariables : MonoBehaviour {
        [Header("Capture Point")] public CapturePoint_SO generatorCapturePoint = null;
        public CapturePoint_SO relaiCapturePoint = null;

        [Header("Field of view")] public FOVManagerSO FOVManager = null;

        [Space(8), Header("Champion 01")] 
        public ChampionSO CHAMP01_BaseVariables = null;
        public ActiveAutoAttackSO CHAMP01_AutoAttack = null;

        [Header("Champion 02")] 
        public ChampionSO CHAMP02_BaseVariables = null;
        public ActiveAutoAttackSO CHAMP02_AutoAttack = null;
    }
}