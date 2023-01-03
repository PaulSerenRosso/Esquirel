using Unity.Services.Authentication;
using Unity.Services.Core;
using System.Threading.Tasks;
using Unity.Services.RemoteConfig;
using UnityEngine;

namespace RemoteConfig {
    public class RemoteConfigManager : MonoBehaviour {
        [SerializeField] private RemoteConfigVariables variables = null;
        [SerializeField] private bool updateAtStart = true;

        private struct userAttributes {}
        private struct appAttributes {}

        /// <summary>
        /// Method called before the start of the game
        /// </summary>
        private async void Awake() {
            if (Utilities.CheckForInternetConnection()) await InitializeRemoteConfigAsync();

            RemoteConfigService.Instance.FetchCompleted += ApplySettings;
            if (updateAtStart) CallFetch();
        }

        /// <summary>
        /// Async Method which allow to wait for connection before doing something else
        /// </summary>
        private async Task InitializeRemoteConfigAsync() {
            await UnityServices.InitializeAsync();

            if (!AuthenticationService.Instance.IsSignedIn) {
                await AuthenticationService.Instance.SignInAnonymouslyAsync();
            }
        }

        /// <summary>
        /// Method which call the appConfig to retrieve all the data and be able to update the value
        /// </summary>
        public void CallFetch() => RemoteConfigService.Instance.FetchConfigs(new userAttributes(), new appAttributes());

        /// <summary>
        /// Method which is called when the fetching is done
        /// </summary>
        /// <param name="configResponse"></param>
        private void ApplySettings(ConfigResponse configResponse) {
            if (configResponse.requestOrigin != ConfigOrigin.Remote) return;

            SetChampion01Variables();
            SetChampion02Variables();
            SetGeneratorVariables();
            SetRelaiVariables();
        }

        /// <summary>
        /// Set the variables of the champion 01 : Esquirrel
        /// </summary>
        private void SetChampion01Variables() {
            //BASE STAT
            variables.CHAMP01_BaseVariables.maxHp = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_BASE_MaxHP");
            variables.CHAMP01_BaseVariables.maxRessource = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_BASE_MaxResources");
            variables.CHAMP01_BaseVariables.viewRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_BASE_ViewRange");
            variables.CHAMP01_BaseVariables.referenceMoveSpeed = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_BASE_MoveSpeed");
            
            //AUTO-ATTACK
            variables.CHAMP01_AutoAttack.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_Cooldown");
            variables.CHAMP01_AutoAttack.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_FxTime");
            variables.CHAMP01_AutoAttack.damageBeginTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_DamageBeginTime");
            variables.CHAMP01_AutoAttack.damageTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_DamageTime");
            variables.CHAMP01_AutoAttack.damage = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_Damage");
            variables.CHAMP01_AutoAttack.width = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_Width");
            variables.CHAMP01_AutoAttack.height = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_Height");
            variables.CHAMP01_AutoAttack.maxRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_MaxRange");
            variables.CHAMP01_AutoAttack.offsetAttack = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_AA_Offset");
            
            //TRINKET
            variables.CHAMP01_Trinket.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_Cooldown");
            variables.CHAMP01_Trinket.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_FxTime");
            variables.CHAMP01_Trinket.trinketDuration = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_Duration");
            variables.CHAMP01_Trinket.trinketViewRadius = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_ViewRadius");
            variables.CHAMP01_Trinket.trinketViewAngle = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_ViewAngle");
            variables.CHAMP01_Trinket.trinketDetectionDistance = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_TRINKET_DetectionDistance");
            
            //CAPACITY 01
            variables.CHAMP01_CAPA01.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_Cooldown");
            variables.CHAMP01_CAPA01.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_FxTime");
            variables.CHAMP01_CAPA01.curveMovementMaxYPosition = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_YPosition");
            variables.CHAMP01_CAPA01.curveMovementTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_TimeLength");
            variables.CHAMP01_CAPA01.referenceRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_ReferenceRange");
            variables.CHAMP01_CAPA01.smokeDuration = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA01_SmokeDuration");
            
            //CAPACITY 02
            variables.CHAMP01_CAPA02.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_Cooldown");
            variables.CHAMP01_CAPA02.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_FxTime");
            variables.CHAMP01_CAPA02.damageBeginTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_DamageBeginTime");
            variables.CHAMP01_CAPA02.damageTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_DamageTime");
            variables.CHAMP01_CAPA02.damage = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_Damage");
            variables.CHAMP01_CAPA02.offsetAttack = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_OffsetAttack");
            variables.CHAMP01_CAPA02.height = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_Height");
            variables.CHAMP01_CAPA02.width = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP01_CAPA02_Width");
        }

        /// <summary>
        /// Set the variables of the champion 01 : Poumf
        /// </summary>
        private void SetChampion02Variables() {
            //BASE STAT
            variables.CHAMP02_BaseVariables.maxHp = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_BASE_MaxHP");
            variables.CHAMP02_BaseVariables.maxRessource = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_BASE_MaxResources");
            variables.CHAMP02_BaseVariables.viewRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_BASE_ViewRange");
            variables.CHAMP02_BaseVariables.referenceMoveSpeed = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_BASE_MoveSpeed");
            
            //TRINKET
            variables.CHAMP02_Trinket.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_Cooldown");
            variables.CHAMP02_Trinket.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_FxTime");
            variables.CHAMP02_Trinket.trinketDuration = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_Duration");
            variables.CHAMP02_Trinket.trinketViewRadius = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_ViewRadius");
            variables.CHAMP02_Trinket.trinketViewAngle = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_ViewAngle");
            variables.CHAMP02_Trinket.trinketDetectionDistance = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_TRINKET_DetectionDistance");
            
            //AUTO-ATTACK
            variables.CHAMP02_AutoAttack.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_Cooldown");
            variables.CHAMP02_AutoAttack.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_FxTime");
            variables.CHAMP02_AutoAttack.damageBeginTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_DamageBeginTime");
            variables.CHAMP02_AutoAttack.damageTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_DamageTime");
            variables.CHAMP02_AutoAttack.damage = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_Damage");
            variables.CHAMP02_AutoAttack.width = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_Width");
            variables.CHAMP02_AutoAttack.height = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_Height");
            variables.CHAMP02_AutoAttack.maxRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_MaxRange");
            variables.CHAMP02_AutoAttack.offsetAttack = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_AA_Offset");

            //CAPACITY 01
            variables.CHAMP02_CAPA01.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_Cooldown");
            variables.CHAMP02_CAPA01.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_FxTime");
            variables.CHAMP02_CAPA01.curveMovementMaxYPosition = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_YPosition");
            variables.CHAMP02_CAPA01.curveMovementTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_TimeLength");
            variables.CHAMP02_CAPA01.referenceRange = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_ReferenceRange");
            variables.CHAMP02_CAPA01_SLOW.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_Cooldown");
            variables.CHAMP02_CAPA01_SLOW.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_FxTime");
            variables.CHAMP02_CAPA01_SLOW.damageBeginTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_DamageBeginTime");
            variables.CHAMP02_CAPA01_SLOW.damageTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_DamageTime");
            variables.CHAMP02_CAPA01_SLOW.damage = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_Damage");
            variables.CHAMP02_CAPA01_SLOW.offsetAttack = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_Offset");
            variables.CHAMP02_CAPA01_SLOW.radiusArea = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_Radius");
            variables.CHAMP02_CAPA01_SLOWEFFECT.speedFactor = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_SpeedFactor");
            variables.CHAMP02_CAPA01_SLOWEFFECT.time = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA01_SLOW_SlowDuration");
            
            //CAPACITY 02
            variables.CHAMP02_CAPA02.cooldown = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_Cooldown");
            variables.CHAMP02_CAPA02.fxTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_FxTime");
            variables.CHAMP02_CAPA02.damageBeginTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_DamageBeginTime");
            variables.CHAMP02_CAPA02.damageTime = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_DamageTime");
            variables.CHAMP02_CAPA02.damage = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_Damage");
            variables.CHAMP02_CAPA02.offsetAttack = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_OffsetAttack");
            variables.CHAMP02_CAPA02.height = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_Height");
            variables.CHAMP02_CAPA02.width = RemoteConfigService.Instance.appConfig.GetFloat("CHAMP02_CAPA02_Width");
            
            //ULTIMATE
        }

        /// <summary>
        /// Set the variables of the generator
        /// </summary>
        private void SetGeneratorVariables() {
            //CAPTURE POINT
            variables.generatorCapturePoint.baseViewRange = RemoteConfigService.Instance.appConfig.GetFloat("GEN_BaseViewRange");
            variables.generatorCapturePoint.viewRange = RemoteConfigService.Instance.appConfig.GetFloat("GEN_ViewRange");
            variables.generatorCapturePoint.capturePointSpeed = RemoteConfigService.Instance.appConfig.GetFloat("GEN_CapturePointSpeed");
            variables.generatorCapturePoint.firstTeamState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM01_StabilityPoint");
            variables.generatorCapturePoint.firstTeamState.captureValue = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM01_CaptureValue");
            variables.generatorCapturePoint.firstTeamState.maxValue = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM01_MaxValue");
            variables.generatorCapturePoint.secondTeamState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM02_StabilityPoint");
            variables.generatorCapturePoint.secondTeamState.captureValue = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM02_CaptureValue");
            variables.generatorCapturePoint.secondTeamState.maxValue = RemoteConfigService.Instance.appConfig.GetFloat("GEN_TEAM02_MaxValue");
            variables.generatorCapturePoint.neutralState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("GEN_NEUTRAL_StabilityPoint");
            
            //PRODUCTION
            variables.generatorProduction.ressourceMax = RemoteConfigService.Instance.appConfig.GetFloat("GEN_PROD_ResourceMax");
            variables.generatorProduction.ressourceMin = RemoteConfigService.Instance.appConfig.GetFloat("GEN_PROD_ResourceMin");
            variables.generatorProduction.ressourceInitial = RemoteConfigService.Instance.appConfig.GetFloat("GEN_PROD_ResourceInitial");
            variables.generatorProduction.timeBetweenTick = RemoteConfigService.Instance.appConfig.GetFloat("GEN_PROD_TimeBetweenTick");
            variables.generatorProduction.ressourceAmountPerTick = RemoteConfigService.Instance.appConfig.GetFloat("GEN_PROD_ResourceAmountPerTick");
        }

        /// <summary>
        /// Set the variables of the relai
        /// </summary>
        private void SetRelaiVariables() {
            //CAPTURE POINT
            variables.relaiCapturePoint.baseViewRange = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_BaseViewRange");
            variables.relaiCapturePoint.viewRange = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_ViewRange");
            variables.relaiCapturePoint.capturePointSpeed = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_CapturePointSpeed");
            variables.relaiCapturePoint.firstTeamState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM01_StabilityPoint");
            variables.relaiCapturePoint.firstTeamState.captureValue = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM01_CaptureValue");
            variables.relaiCapturePoint.firstTeamState.maxValue = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM01_MaxValue");
            variables.relaiCapturePoint.secondTeamState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM02_StabilityPoint");
            variables.relaiCapturePoint.secondTeamState.captureValue = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM02_CaptureValue");
            variables.relaiCapturePoint.secondTeamState.maxValue = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_TEAM02_MaxValue");
            variables.relaiCapturePoint.neutralState.stabilityPoint = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_NEUTRAL_StabilityPoint");
            
            //PRODUCTION
            variables.relaiProduction.ressourceMax = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_PROD_ResourceMax");
            variables.relaiProduction.ressourceMin = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_PROD_ResourceMin");
            variables.relaiProduction.ressourceInitial = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_PROD_ResourceInitial");
            variables.relaiProduction.timeBetweenTick = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_PROD_TimeBetweenTick");
            variables.relaiProduction.ressourceAmountPerTick = RemoteConfigService.Instance.appConfig.GetFloat("RELAI_PROD_ResourceAmountPerTick");
        }
    }
}