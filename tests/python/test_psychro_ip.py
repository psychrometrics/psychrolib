from src.python.psychro_ip import (GetRankineFromFahrenheit,
GetStandardAtmTemperature
)

def test_GetRankineFromFahrenheit():
    assert GetRankineFromFahrenheit(20) == 479.67

def test_GetStandardAtmTemperature():
    assert GetStandardAtmTemperature(1000) == 55.4338