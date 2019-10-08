namespace PsychroLib
{
    /// <summary>
    /// Contains output results of a Psychrometric calculation.
    /// </summary>
    public class PsychrometricValue
    {

        /// <summary>
        /// Dry bulb temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TDryBulb { get; set; }

        /// <summary>
        /// Wet bulb temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TWetBulb { get; set; }

        /// <summary>
        /// Atmospheric pressure in Psi [IP] or Pa [SI]
        /// </summary>
        public double Pressure { get; set; }

        /// <summary>
        /// Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        /// </summary>
        public double HumRatio { get; set; }

        /// <summary>
        /// Dew point temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TDewPoint { get; set; }

        /// <summary>
        /// Relative humidity [0-1]
        /// </summary>
        public double RelHum { get; set; }

        /// <summary>
        /// Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        /// </summary>
        public double VapPres { get; set; }

        /// <summary>
        /// Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
        /// </summary>
        public double MoistAirEnthalpy { get; set; }

        /// <summary>
        /// Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
        /// </summary>
        public double MoistAirVolume { get; set; }

        /// <summary>
        /// Degree of saturation [unitless]
        /// </summary>
        public double DegreeOfSaturation { get; set; }
    }
}