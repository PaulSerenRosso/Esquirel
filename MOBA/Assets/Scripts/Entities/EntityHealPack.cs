using System;
using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Champion;
using UnityEngine;

public class EntityHealPack : MonoBehaviour
{
    public float valueToHeal;
    public float timeBetweenHeal;
    public List<Entity> championsToHeal;

    private bool _isHealCalled = false;
    
    private void Update()
    {
        if (championsToHeal != null && !_isHealCalled)
        {
            Invoke("ApplyHeal", timeBetweenHeal);
            _isHealCalled = true;
        }
    }

    private void ApplyHeal()
    {
        foreach (var entity in championsToHeal)
        {
            entity.GetComponent<Entities.Champion.Champion>().IncreaseCurrentHpRPC(valueToHeal);
        }

        _isHealCalled = false;
    }
}
