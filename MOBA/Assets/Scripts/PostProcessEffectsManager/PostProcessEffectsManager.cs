using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessEffectsManager : MonoBehaviour
{
    // Start is called before the first frame update

    public static PostProcessEffectsManager Instance;

    [SerializeField] private Material postProcessEffectMaterial;
    [SerializeField] private float damageEffectApparitionTime;
    [SerializeField] private float damageEffectDisappearanceTime;
    private float damageEffectTimer;

    private bool isActiveLowHpEffect;
    private byte damageEffectState;
    [SerializeField] private float hpInPercentageTriggerLowHpEffect;

    [SerializeField] private float grayScaleApparitionTime;
    [SerializeField] private float grayScaleDisappearanceTime;
    private float grayScaleTimer; 
    private byte grayScaleState;
    [SerializeField] private float maxGrayScaleOpacity;
    private void Awake()
    {
        Instance = this;
    }

    public void LaunchDamageEffect()
    {
        if (damageEffectState != 0) return;
        damageEffectState = 1;
    }

    void ActivateLowHpEffect()
    {
        postProcessEffectMaterial.SetFloat("_OpacityBloodEffect", 1);
        isActiveLowHpEffect = true;
    }

    void DeactivateLowHpEffect()
    {
        postProcessEffectMaterial.SetFloat("_OpacityBloodEffect", 0);
        isActiveLowHpEffect = false;
    }

    private void ResetDamageEffect()
    {
        damageEffectState = 0;
        damageEffectTimer = 0;
        postProcessEffectMaterial.SetFloat("_OpacityImpactEffect", 0);
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
        UpdateDamageEffect();
        UpdateGrayScaleEffect();
    }

    public void ActivateGrayScaleEffect()
    {
        grayScaleState = 1;
        grayScaleTimer = 0;
    }

    public void DeactivateGrayScaleEffect()
    {
        grayScaleTimer = 0;
        grayScaleState = 2;
    }
     void UpdateGrayScaleEffect()
    {
        if (grayScaleState != 0)
        {
            grayScaleTimer += Time.deltaTime;
            
            if (grayScaleState == 1)
            {
                postProcessEffectMaterial.SetFloat("_OpacityGrayscaleEffect",
                    Mathf.Clamp( maxGrayScaleOpacity*(grayScaleTimer /grayScaleApparitionTime), 0, maxGrayScaleOpacity));
                if ( grayScaleTimer >= grayScaleApparitionTime)
                {
                    grayScaleTimer = 0;
                    grayScaleState = 0;
                }
            }
            else
            {
                postProcessEffectMaterial.SetFloat("_OpacityGrayscaleEffect",
                    Mathf.Clamp( maxGrayScaleOpacity- (maxGrayScaleOpacity*(grayScaleTimer/ grayScaleDisappearanceTime)), 0, maxGrayScaleOpacity));
                if (grayScaleTimer >= grayScaleDisappearanceTime)
                {
                    grayScaleTimer = 0;
                    grayScaleState = 0;
                }
            }
        }
    }

    private void UpdateDamageEffect()
    {
        if (damageEffectState != 0)
        {
            damageEffectTimer += Time.deltaTime;
            
            if (damageEffectState == 1)
            {
                postProcessEffectMaterial.SetFloat("_OpacityImpactEffect",
                    Mathf.Clamp(damageEffectTimer / damageEffectApparitionTime, 0, 1));
                if (damageEffectTimer >= damageEffectApparitionTime)
                {
                    damageEffectTimer = 0;
                    damageEffectState = 2;
                }
            }
            else
            {
                postProcessEffectMaterial.SetFloat("_OpacityImpactEffect",
                    Mathf.Clamp(1 - (damageEffectTimer / damageEffectDisappearanceTime), 0, 1));
                if (damageEffectTimer >= damageEffectDisappearanceTime)
                {
                    ResetDamageEffect();
                }
            }
        }
    }

    
}