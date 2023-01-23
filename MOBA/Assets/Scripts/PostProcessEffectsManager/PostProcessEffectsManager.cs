using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessEffectsManager : MonoBehaviour
{
    // Start is called before the first frame update

    public static PostProcessEffectsManager Instance;

    [SerializeField] private Material hpEffect;
    [SerializeField] private float damageEffectApparitionTime;
    [SerializeField] private float damageEffectDisappearanceTime;
    private float damageEffectTimer;

    private bool isActiveLowHpEffect;
    private int damageEffectState;
    [SerializeField] private float hpInPercentageTriggerLowHpEffect;

    private void Awake()
    {
        Instance = this;
    }

    public void LaunchDamageEffect()
    {
        if(damageEffectState != 0) return;
        damageEffectState = 1;
    }

    void ActivateLowHpEffect()
    {
        hpEffect.SetFloat("_OpacityBloodEffect", 1);
        isActiveLowHpEffect = true;
    }

    void DeactivateLowHpEffect()
    {
        hpEffect.SetFloat("_OpacityBloodEffect", 0);
        isActiveLowHpEffect = false;
    }

    private void ResetDamageEffect()
    {
        damageEffectState = 0;
        damageEffectTimer = 0;
        hpEffect.SetFloat("_OpacityImpactEffect", 0);
    }

    public void UpdateLowHpEffect(float hp, float maxHp)
    {
        if (hp <= hpInPercentageTriggerLowHpEffect * maxHp)
        {
            if (!isActiveLowHpEffect)
            {
                ActivateLowHpEffect();
            }
        }
        else
        {
            if (isActiveLowHpEffect)
            {
                DeactivateLowHpEffect();
            }
        }
    }
    private void Update()
    {
        if (damageEffectState == 0) return;

        damageEffectTimer += Time.deltaTime;
      
        
        if (damageEffectState == 1)
        {
            hpEffect.SetFloat("_OpacityImpactEffect", Mathf.Clamp(damageEffectTimer / damageEffectApparitionTime, 0 , 1));
            if (damageEffectTimer >= damageEffectApparitionTime)
            {
                damageEffectTimer = 0;
                damageEffectState = 2;
            }
        }
        else
        {
            hpEffect.SetFloat("_OpacityImpactEffect", Mathf.Clamp(1-(damageEffectTimer / damageEffectDisappearanceTime),0 ,1));
            if (damageEffectTimer >= damageEffectDisappearanceTime)
            {
                ResetDamageEffect();
            }
        }
    }
}