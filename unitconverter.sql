CREATE OR REPLACE PACKAGE unit_converter AS
    FUNCTION convert_value(
        p_quantity   IN VARCHAR2,
        p_source     IN VARCHAR2,
        p_target     IN VARCHAR2,
        p_value      IN NUMBER
    ) RETURN NUMBER;
END unit_converter;
/


CREATE OR REPLACE PACKAGE BODY unit_converter AS

    FUNCTION convert_value(
        p_quantity   IN VARCHAR2,
        p_source     IN VARCHAR2,
        p_target     IN VARCHAR2,
        p_value      IN NUMBER
    ) RETURN NUMBER IS
        v_result NUMBER;
    BEGIN

        --------------------------------------------------------------------
        -- DATA SIZE CONVERSION
        --------------------------------------------------------------------
        IF p_quantity = 'data_sizes' THEN
            -- Define conversion factors
            DECLARE
                FUNCTION factor(u VARCHAR2) RETURN NUMBER IS
                BEGIN
                    CASE u
                        WHEN 'bytes'      THEN RETURN 1;
                        WHEN 'kilobytes'  THEN RETURN 1024;
                        WHEN 'megabytes'  THEN RETURN POWER(1024, 2);
                        WHEN 'gigabytes'  THEN RETURN POWER(1024, 3);
                        WHEN 'terabytes'  THEN RETURN POWER(1024, 4);
                        ELSE RETURN NULL;
                    END CASE;
                END;
            BEGIN
                v_result := p_value * factor(p_source) / factor(p_target);
            END;

        --------------------------------------------------------------------
        -- HEIGHT CONVERSION
        --------------------------------------------------------------------
        ELSIF p_quantity = 'height' THEN
            CASE p_source
                WHEN 'meters' THEN
                    CASE p_target
                        WHEN 'centimeters' THEN v_result := p_value * 100;
                        WHEN 'feet'        THEN v_result := p_value * 3.28084;
                        WHEN 'inches'      THEN v_result := p_value * 39.3701;
                    END CASE;

                WHEN 'centimeters' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value / 100;
                        WHEN 'feet'       THEN v_result := p_value * 0.0328084;
                        WHEN 'inches'     THEN v_result := p_value * 0.393701;
                    END CASE;

                WHEN 'feet' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value / 3.28084;
                        WHEN 'centimeters' THEN v_result := p_value * 30.48;
                        WHEN 'inches'     THEN v_result := p_value * 12;
                    END CASE;

                WHEN 'inches' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value / 39.3701;
                        WHEN 'centimeters' THEN v_result := p_value * 2.54;
                        WHEN 'feet'       THEN v_result := p_value / 12;
                    END CASE;
            END CASE;

        --------------------------------------------------------------------
        -- WEIGHT CONVERSION
        --------------------------------------------------------------------
        ELSIF p_quantity = 'weight' THEN
            CASE p_source
                WHEN 'kilograms' THEN
                    CASE p_target
                        WHEN 'grams'   THEN v_result := p_value * 1000;
                        WHEN 'pounds'  THEN v_result := p_value * 2.20462;
                        WHEN 'ounces'  THEN v_result := p_value * 35.274;
                    END CASE;

                WHEN 'grams' THEN
                    CASE p_target
                        WHEN 'kilograms' THEN v_result := p_value / 1000;
                        WHEN 'pounds'    THEN v_result := p_value * 0.00220462;
                        WHEN 'ounces'    THEN v_result := p_value * 0.035274;
                    END CASE;

                WHEN 'pounds' THEN
                    CASE p_target
                        WHEN 'kilograms' THEN v_result := p_value / 2.20462;
                        WHEN 'grams'     THEN v_result := p_value * 453.592;
                        WHEN 'ounces'    THEN v_result := p_value * 16;
                    END CASE;

                WHEN 'ounces' THEN
                    CASE p_target
                        WHEN 'kilograms' THEN v_result := p_value / 35.274;
                        WHEN 'grams'     THEN v_result := p_value * 28.3495;
                        WHEN 'pounds'    THEN v_result := p_value / 16;
                    END CASE;
            END CASE;

        --------------------------------------------------------------------
        -- TEMPERATURE CONVERSION
        --------------------------------------------------------------------
        ELSIF p_quantity = 'temperature' THEN
            CASE p_source
                WHEN 'Celsius' THEN
                    CASE p_target
                        WHEN 'Fahrenheit' THEN v_result := (p_value * 9/5) + 32;
                        WHEN 'Kelvin'     THEN v_result := p_value + 273.15;
                    END CASE;

                WHEN 'Fahrenheit' THEN
                    CASE p_target
                        WHEN 'Celsius' THEN v_result := (p_value - 32) * 5/9;
                        WHEN 'Kelvin'  THEN v_result := (p_value - 32) * 5/9 + 273.15;
                    END CASE;

                WHEN 'Kelvin' THEN
                    CASE p_target
                        WHEN 'Celsius'    THEN v_result := p_value - 273.15;
                        WHEN 'Fahrenheit' THEN v_result := (p_value - 273.15) * 9/5 + 32;
                    END CASE;
            END CASE;

        --------------------------------------------------------------------
        -- DISTANCE CONVERSION
        --------------------------------------------------------------------
        ELSIF p_quantity = 'distance' THEN
            CASE p_source
                WHEN 'meters' THEN
                    CASE p_target
                        WHEN 'kilometers' THEN v_result := p_value / 1000;
                        WHEN 'miles'      THEN v_result := p_value * 0.000621371;
                        WHEN 'yards'      THEN v_result := p_value * 1.09361;
                    END CASE;

                WHEN 'kilometers' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value * 1000;
                        WHEN 'miles'      THEN v_result := p_value * 0.621371;
                        WHEN 'yards'      THEN v_result := p_value * 1093.61;
                    END CASE;

                WHEN 'miles' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value / 0.000621371;
                        WHEN 'kilometers' THEN v_result := p_value / 0.621371;
                        WHEN 'yards'      THEN v_result := p_value * 1760;
                    END CASE;

                WHEN 'yards' THEN
                    CASE p_target
                        WHEN 'meters'     THEN v_result := p_value / 1.09361;
                        WHEN 'kilometers' THEN v_result := p_value / 1093.61;
                        WHEN 'miles'      THEN v_result := p_value / 1760;
                    END CASE;
            END CASE;

        END IF;

        RETURN v_result;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid conversion input.');
    END convert_value;

END unit_converter;
/
