using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.FogOfWar
{
public class SmokeBush : Bush
{
    [SerializeField] private Smoke smoke;
    public override bool IsNeededToViewEntityInsideBushForSeeShowableEntity( Entity viewableEntity, Entity showableEntity)
    {
        if (viewableEntity.team == smoke.team)
        {
            return false;
        }
        else
        {
            if (viewableEntity.team != showableEntity.team)
            {
                return true;
            }
            return false;
        }
    }

    private void OnDisable()
    {
        for (int i = 0; i < entitiesInside.Count; i++)
        {
            entitiesInside[i].bushes.Remove(this);
        }
        entitiesInside.Clear();
    }

    public override bool CheckBushMaskView(Entity viewableEntity)
    {
        if (viewableEntity.team == smoke.team)
            return false;
        else if (base.CheckBushMaskView(viewableEntity)) return true;
        return false;
    }
}
    
}
