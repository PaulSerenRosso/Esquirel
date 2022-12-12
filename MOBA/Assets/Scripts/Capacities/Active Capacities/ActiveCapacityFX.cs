using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveCapacityFX : Entity
{
    public virtual void InitCapacityFX(ActiveCapacity capacity)
    {
        team = capacity.caster.team;
    }
}

}
