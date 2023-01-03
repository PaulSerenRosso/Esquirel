using CapturePoint;
using Entities.Capacities;
using Entities.Champion;
using Entities.FogOfWar;
using RessourceProduction;
using UnityEngine;

namespace RemoteConfig {
    public class RemoteConfigVariables : MonoBehaviour {
        [Header("Capture Point")] 
        public CapturePointSO generatorCapturePoint = null;
        public CapturePointSO relaiCapturePoint = null;
        public GoldProductionSO relaiProduction = null;
        public VictoryProductionSO generatorProduction = null;
        
        [Space(8), Header("Champion 01")]
        public ChampionSO CHAMP01_BaseVariables = null;
        public ActiveAutoAttackSO CHAMP01_AutoAttack = null;
        public ActiveTrinketCapacitySO CHAMP01_Trinket = null;
        public TpCapacitySO CHAMP01_CAPA01 = null;
        public SwordAttackSO CHAMP01_CAPA02 = null;

        [Header("Champion 02")]
        public ChampionSO CHAMP02_BaseVariables = null;
        public ActiveAutoAttackSO CHAMP02_AutoAttack = null;
        public ActiveTrinketCapacitySO CHAMP02_Trinket = null;
        public JumpWithSlowCapacityCapacitySO CHAMP02_CAPA01 = null;
        public ActiveAttackSlowAreaCapacitySO CHAMP02_CAPA01_SLOW = null;
        public PassiveSpeedSO CHAMP02_CAPA01_SLOWEFFECT = null;
        public TailAttackSO CHAMP02_CAPA02 = null;
    }
}