/**********************************
 * 1551-rePico board init: GPIO0 PHI0 PWM; GPIO3 DEVNUM or optional IRQ PWM
***********************************/
#include "pico/stdlib.h"
#include "hardware/pwm.h"
#include "hardware/clocks.h"

#include "board1551.h"
#include "pinout.h"

#if REPICO1551

static void calc_pwm_params(uint32_t freq_hz, float *div_out, uint32_t *top_out, uint32_t *period_out)
{
    const uint32_t clock_hz = clock_get_hz(clk_sys);
    float div = 1.0f;
    uint32_t top = (uint32_t)((uint64_t)clock_hz / (uint64_t)div / (uint64_t)freq_hz) - 1u;

    while (top > 65534u) {
        div += 1.0f;
        top = (uint32_t)((uint64_t)clock_hz / (uint64_t)div / (uint64_t)freq_hz) - 1u;
    }

    if (top < 1u) {
        top = 1u;
    }

    *div_out = div;
    *top_out = top;
    *period_out = top + 1u;
}

static void start_pwm(uint gpio, float div, uint32_t top, uint32_t level)
{
    gpio_set_function(gpio, GPIO_FUNC_PWM);

    const uint slice = pwm_gpio_to_slice_num(gpio);
    const uint channel = pwm_gpio_to_channel(gpio);

    pwm_config cfg = pwm_get_default_config();
    pwm_config_set_clkdiv(&cfg, div);
    pwm_config_set_wrap(&cfg, top);
    pwm_init(slice, &cfg, true);
    pwm_set_chan_level(slice, channel, level);
}

static void init_gpio3_devnum_device8(void)
{
    gpio_init(GPIO_SOE_GA);
    gpio_set_dir(GPIO_SOE_GA, GPIO_OUT);
    gpio_put(GPIO_SOE_GA, REPICO1551_DEVNUM_DEVICE8_LEVEL);
}

#if defined(REPICO1551_GPIO3_IRQ_PWM)
static void init_gpio3_irq_pwm(void)
{
    float div;
    uint32_t top;
    uint32_t period;

    calc_pwm_params(REPICO1551_IRQ_HZ, &div, &top, &period);
    uint32_t low_counts = (uint32_t)(((uint64_t)period * REPICO1551_IRQ_LOW_US * REPICO1551_IRQ_HZ) / 1000000ull);
    if (low_counts < 1u) {
        low_counts = 1u;
    }
    if (low_counts >= period) {
        low_counts = period - 1u;
    }
    const uint32_t level = top - low_counts;
    start_pwm(GPIO_SOE_GA, div, top, level);
}
#endif

void init_board1551(void)
{
    float div;
    uint32_t top;
    uint32_t period;

    // GPIO0: 2 MHz PHI0, 50% duty cycle (isolated from /PHI0 until JP2 experiment bridge)
    calc_pwm_params(REPICO1551_PHI0_HZ, &div, &top, &period);
    start_pwm(GPIO_SOE, div, top, top / 2u);

#if defined(REPICO1551_GPIO3_IRQ_PWM)
    init_gpio3_irq_pwm();
#else
    init_gpio3_devnum_device8();
#endif
}

#endif
