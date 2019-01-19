/*
 * Copyright (C) 2019  Belle-Isle, Andrew <drumsetmonkey@gmail.com>
 * Author: Belle-Isle, Andrew <drumsetmonkey@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef CLOCK_H
#define CLOCK_H

#include "stm32h743xx.h"

/**
 * Initialize the System Tick interrupt for clock ticks
 */
void Clock_Init(void);

/**
 * Delay current execution for a certain number of milliseconds.
 * NOTE: This function will be running for however many ms are passed
 *  into this function.
 * @param delay How many milliseconds to delay the program.
 */
void Clock_Delay(uint32_t delay);

#endif // CLOCK_H
